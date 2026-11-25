import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/user_avatar_service.dart';

/// Cooperative cancellation token so leaving the Try-On screen aborts
/// active requests immediately and prevents any further API credit usage.
class TryOnCancellationToken {
  bool _isCancelled = false;
  final Set<HttpClient> _activeClients = {};
  final List<VoidCallback> _listeners = [];

  bool get isCancelled => _isCancelled;

  void addListener(VoidCallback cb) {
    if (_isCancelled) {
      cb();
    } else {
      _listeners.add(cb);
    }
  }

  void removeListener(VoidCallback cb) => _listeners.remove(cb);

  void registerClient(HttpClient client) {
    if (_isCancelled) {
      try {
        client.close(force: true);
      } catch (_) {}
      return;
    }
    _activeClients.add(client);
  }

  void unregisterClient(HttpClient client) => _activeClients.remove(client);

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final client in List<HttpClient>.from(_activeClients)) {
      try {
        client.close(force: true);
      } catch (_) {}
    }
    _activeClients.clear();
    for (final listener in List<VoidCallback>.from(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
    _listeners.clear();
  }
}

class FashnTryOnResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? tryOnImageUrl;
  final String? glbModelUrl;
  final String? remoteGlbUrl;
  final String? errorMessage;
  final double processingTimeSec;

  const FashnTryOnResult({
    required this.isSuccess,
    this.isCancelled = false,
    this.tryOnImageUrl,
    this.glbModelUrl,
    this.remoteGlbUrl,
    this.errorMessage,
    this.processingTimeSec = 0.0,
  });
}

class FashnTryOnService {
  static final FashnTryOnService instance = FashnTryOnService._internal();
  FashnTryOnService._internal();

  static const String _baseUrl = 'https://api.fashn.ai/v1';
  static const String _tripoBaseUrl = 'https://openapi.tripo3d.ai/v3';
  static const String _supabaseUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co';

  // Fallback API key provided by client
  static const String _defaultApiKey = 'fa-XFaXmT3GPiNH-wnpGLqDJ2sBjBupHGlVw8SvW';
  static const String _defaultTripoKey = 'tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw';

  String get _apiKey {
    final key = dotenv.env['FASHN_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  String get _tripoKey {
    final key = dotenv.env['TRIPO_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultTripoKey;
  }

  // In-memory cache scoped by user + product to avoid redundant API credit consumption
  static final Map<String, String> _tryOnCache = {};
  static final Map<String, String> _tryOnGlbCache = {};
  static final Map<String, String> _localGlbFileCache = {};

  static void clearMemoryCache() {
    _tryOnCache.clear();
    _tryOnGlbCache.clear();
    _localGlbFileCache.clear();
  }

  static String _userScope() => Supabase.instance.client.auth.currentUser?.id ?? 'guest';

  static String _scopedKey(String rawKey) => '${_userScope()}_$rawKey';

  static String _safeSlug(String raw) => raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  static bool _isValidTryOnGlb(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url.contains('base_avatar') ||
        url.contains('avatar_blazer_tryon') ||
        url.contains('avatar_dressed') ||
        url.contains('avatar_runway_catwalk')) {
      return false;
    }
    if (url.contains('tripo3d.com') || url.contains('tripo3d.ai')) {
      // Signed Tripo links expire cleanly; only accept permanent Supabase / local files
      return false;
    }
    return url.startsWith('http') || url.startsWith('file://');
  }

  static String? getCachedTryOn(String cacheKey) =>
      _tryOnCache[_scopedKey(cacheKey)] ?? _tryOnCache[cacheKey];

  static String? getCachedGlb(String cacheKey) {
    final local = _localGlbFileCache[_scopedKey(cacheKey)] ?? _localGlbFileCache[cacheKey];
    if (local != null && local.isNotEmpty) {
      final path = local.startsWith('file://') ? Uri.parse(local).toFilePath() : local;
      if (File(path).existsSync()) {
        return local.startsWith('file://') ? local : Uri.file(path).toString();
      }
    }
    return _tryOnGlbCache[_scopedKey(cacheKey)] ?? _tryOnGlbCache[cacheKey];
  }

  /// Synchronous memory check: does this product already have a cached 3D try-on?
  static bool hasCachedTryOn(String? productId, [String? garmentImagePath]) {
    final uid = _userScope();
    if (productId != null && productId.isNotEmpty) {
      final glb = getCachedGlb(productId) ?? _tryOnGlbCache['${uid}_$productId'];
      if (_isValidTryOnGlb(glb)) return true;
    }
    if (garmentImagePath != null && garmentImagePath.isNotEmpty && productId != null && productId.isNotEmpty) {
      final combo = '${productId}_$garmentImagePath';
      final glb = getCachedGlb(combo) ?? _tryOnGlbCache['${uid}_$combo'];
      if (_isValidTryOnGlb(glb)) return true;
    }
    return false;
  }

  /// Asynchronous check across memory, disk SharedPreferences, and Supabase wardrobe_items.
  Future<bool> checkHasCachedTryOn(String? productId, [String? garmentImagePath]) async {
    if (hasCachedTryOn(productId, garmentImagePath)) return true;
    final resolved = await resolveCachedTryOn(
      productId: productId,
      garmentImagePath: garmentImagePath ?? '',
      downloadLocalIfMissing: false,
    );
    return resolved != null && resolved.isSuccess && _isValidTryOnGlb(resolved.glbModelUrl);
  }

  /// Resolves any saved try-on for this user & product across Memory -> Disk -> Supabase.
  Future<FashnTryOnResult?> resolveCachedTryOn({
    required String? productId,
    required String garmentImagePath,
    String? productName,
    String? cacheKey,
    bool downloadLocalIfMissing = true,
    TryOnCancellationToken? cancelToken,
  }) async {
    final uid = _userScope();
    final key = cacheKey ?? '${productId ?? ""}_$garmentImagePath';
    final scopedCombo = '${uid}_v2_$key';
    final scopedProd = (productId != null && productId.isNotEmpty) ? '${uid}_v2_$productId' : null;

    String? cachedImg = getCachedTryOn(key) ?? (productId != null ? getCachedTryOn(productId) : null);
    String? cachedGlb = getCachedGlb(key) ?? (productId != null ? getCachedGlb(productId) : null);
    String? localGlbUri;

    // 1. Check SharedPreferences user-scoped v2 disk cache & local GLB file
    try {
      final prefs = await SharedPreferences.getInstance();
      cachedImg ??= prefs.getString('tryon_img_$scopedCombo') ??
          (scopedProd != null ? prefs.getString('tryon_img_$scopedProd') : null);

      final prefGlb = prefs.getString('tryon_glb_$scopedCombo') ??
          (scopedProd != null ? prefs.getString('tryon_glb_$scopedProd') : null);
      if (_isValidTryOnGlb(prefGlb)) {
        cachedGlb ??= prefGlb;
      }

      final prefLocal = prefs.getString('tryon_local_$scopedCombo') ??
          (scopedProd != null ? prefs.getString('tryon_local_$scopedProd') : null);
      if (prefLocal != null && prefLocal.isNotEmpty) {
        final f = File(prefLocal);
        if (await f.exists() && await f.length() > 10000) {
          localGlbUri = Uri.file(prefLocal).toString();
        }
      }
    } catch (_) {}

    // 2. Check Supabase wardrobe_items (survives app restart, refresh, and reinstall!)
    final user = Supabase.instance.client.auth.currentUser;
    if ((cachedImg == null || !_isValidTryOnGlb(cachedGlb)) &&
        user != null &&
        productId != null &&
        productId.isNotEmpty) {
      try {
        final rows = await Supabase.instance.client
            .from('wardrobe_items')
            .select('tryon_image_url, glb_model_url, is_worn_in_3d')
            .eq('user_id', user.id)
            .eq('product_id', productId)
            .order('created_at', ascending: false)
            .limit(1);

        if (rows.isNotEmpty) {
          final existing = rows.first;
          final sImg = existing['tryon_image_url'] as String?;
          final sGlb = existing['glb_model_url'] as String?;
          final worn = existing['is_worn_in_3d'] == true;
          if (sImg != null && sImg.isNotEmpty && sImg.startsWith('http')) {
            cachedImg ??= sImg;
          }
          if (worn && _isValidTryOnGlb(sGlb)) {
            cachedGlb = sGlb;
          }
        }
      } catch (dbErr) {
        debugPrint('[FashnTryOnService] Supabase cache lookup note: $dbErr');
      }
    }

    if (cancelToken?.isCancelled == true) return null;

    if (_isValidTryOnGlb(cachedGlb) || (localGlbUri != null && localGlbUri.isNotEmpty)) {
      String effectiveRemote = _isValidTryOnGlb(cachedGlb) ? cachedGlb! : '';

      // Ensure local cached GLB file exists on disk so WebView renders reliably & offline
      if (localGlbUri == null && downloadLocalIfMissing && effectiveRemote.startsWith('http')) {
        localGlbUri = await _ensureLocalGlbCached(
          remoteUrl: effectiveRemote,
          scopedCombo: scopedCombo,
          scopedProd: scopedProd,
          cancelToken: cancelToken,
        );
      }

      if (cancelToken?.isCancelled == true) return null;

      final runnableGlb = (effectiveRemote.isNotEmpty ? effectiveRemote : null) ?? localGlbUri;
      if (runnableGlb != null && runnableGlb.isNotEmpty) {
        await _saveToMemoryAndPrefs(
          key: key,
          productId: productId,
          imageUrl: cachedImg,
          remoteGlbUrl: effectiveRemote.isNotEmpty ? effectiveRemote : runnableGlb,
          localFilePath: localGlbUri != null ? Uri.parse(localGlbUri).toFilePath() : null,
        );
        if (cachedImg != null && cachedImg.isNotEmpty) {
          UserAvatarService.setLatestTryOn(glbUrl: runnableGlb, imageUrl: cachedImg);
        } else {
          UserAvatarService.setLatestTryOn(glbUrl: runnableGlb);
        }
        return FashnTryOnResult(
          isSuccess: true,
          tryOnImageUrl: cachedImg,
          glbModelUrl: runnableGlb,
          remoteGlbUrl: effectiveRemote.isNotEmpty ? effectiveRemote : runnableGlb,
          processingTimeSec: 0.01,
        );
      }
    }

    return null;
  }

  /// Executes full 2D AI Virtual Try-On + 3D Mesh + Rigging + Motion Retargeting pipeline.
  Future<FashnTryOnResult> executeTryOn({
    required String garmentImagePath,
    String? productId,
    String? productName,
    String? productBrand,
    String? productPrice,
    File? userAvatarFile,
    String? userAvatarUrl,
    String category = 'tops',
    double heightCm = 170.0,
    bool isMale = true,
    TryOnCancellationToken? cancelToken,
    void Function(String message)? onProgress,
    void Function(String imageUrl)? onImageReady,
    void Function(String glbUrl)? onGlbReady,
    String? cacheKey,
    bool forceRegenerate = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final key = cacheKey ?? '${productId ?? ""}_$garmentImagePath';
    final effectiveTitle = (productName != null && productName.isNotEmpty) ? productName : category;

    if (cancelToken?.isCancelled == true) {
      return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
    }

    // 1. Check existing complete try-on across Memory -> Local Disk -> Supabase DB
    if (!forceRegenerate) {
      final cached = await resolveCachedTryOn(
        productId: productId,
        garmentImagePath: garmentImagePath,
        productName: effectiveTitle,
        cacheKey: key,
        cancelToken: cancelToken,
      );
      if (cancelToken?.isCancelled == true) {
        return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
      }
      if (cached != null && cached.isSuccess && _isValidTryOnGlb(cached.glbModelUrl)) {
        if (cached.tryOnImageUrl != null) onImageReady?.call(cached.tryOnImageUrl!);
        if (cached.glbModelUrl != null) onGlbReady?.call(cached.glbModelUrl!);
        debugPrint('[FashnTryOnService] Complete try-on served from cache (0.01s)! Key: $key');
        return cached;
      }
    } else {
      // Clean memory cache on force regenerate
      _tryOnCache.remove(key);
      _tryOnCache.remove(_scopedKey(key));
      _tryOnGlbCache.remove(key);
      _tryOnGlbCache.remove(_scopedKey(key));
      _localGlbFileCache.remove(key);
      _localGlbFileCache.remove(_scopedKey(key));
      if (productId != null && productId.isNotEmpty) {
        _tryOnCache.remove(productId);
        _tryOnCache.remove(_scopedKey(productId));
        _tryOnGlbCache.remove(productId);
        _tryOnGlbCache.remove(_scopedKey(productId));
      }
    }

    // 2. Check if 2D try-on image already succeeded in memory (avoid double-charging 2D if retry)
    String? permanent2DUrl = forceRegenerate ? null : (getCachedTryOn(key) ?? (productId != null ? getCachedTryOn(productId) : null));

    try {
      if (permanent2DUrl == null || permanent2DUrl.isEmpty) {
        onProgress?.call("Tailoring garment to your proportions...");

        final garmentInput = await _resolveImageInput(garmentImagePath);
        final modelInput = await _resolveModelImageInput(
          userAvatarFile: userAvatarFile,
          userAvatarUrl: userAvatarUrl,
          isMale: isMale,
        );

        if (cancelToken?.isCancelled == true) {
          return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
        }

        final generated2DUrl = await _runFashnTryOnStage(
          modelInput: modelInput,
          garmentInput: garmentInput,
          garmentImagePath: garmentImagePath,
          category: category,
          productTitle: effectiveTitle,
          heightCm: heightCm,
          isMale: isMale,
          allowFallbackRetry: userAvatarFile != null,
          cancelToken: cancelToken,
          onProgress: onProgress,
        );

        if (cancelToken?.isCancelled == true) {
          return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
        }

        if (generated2DUrl == null || generated2DUrl.isEmpty) {
          return FashnTryOnResult(
            isSuccess: false,
            errorMessage: _lastFashnError ?? 'Virtual fitting could not be completed. Please try again.',
          );
        }

        // Persist 2D PNG to Supabase Storage so it NEVER expires after 3 days
        onProgress?.call("Finalizing studio portrait fitting...");
        final raw2DBytes = await _fetchImageBytes(generated2DUrl, cancelToken: cancelToken);
        if (cancelToken?.isCancelled == true) {
          return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
        }

        if (raw2DBytes != null && raw2DBytes.isNotEmpty) {
          final uploadedImgUrl = await _uploadBytesToSupabaseStorage(
            bytes: raw2DBytes,
            fileName: 'tryon_img_${_safeSlug(_userScope())}_${DateTime.now().millisecondsSinceEpoch}.png',
            contentType: 'image/png',
            cancelToken: cancelToken,
          );
          permanent2DUrl = uploadedImgUrl ?? generated2DUrl;
        } else {
          permanent2DUrl = generated2DUrl;
        }

        if (cancelToken?.isCancelled == true) {
          return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
        }

        // Keep 2D in memory ONLY for current session (don't persist to DB/disk until 3D succeeds,
        // so cancelling mid-3D wipes cleanly!)
        _tryOnCache[_scopedKey(key)] = permanent2DUrl;
        if (productId != null && productId.isNotEmpty) {
          _tryOnCache[_scopedKey(productId)] = permanent2DUrl;
        }
        onImageReady?.call(permanent2DUrl);
        UserAvatarService.setLatestTryOn(imageUrl: permanent2DUrl);
      } else {
        onImageReady?.call(permanent2DUrl);
      }

      if (cancelToken?.isCancelled == true) {
        _wipeMemoryCacheForProduct(key, productId);
        return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
      }

      // 3. Stage 2: 3D Mesh + Skeleton Auto-Rigging + Multi-Track Runway Animation
      onProgress?.call("Generating 3D Body Garment Avatar...");
      final glbBundle = await _generateTripo3DModel(
        permanent2DUrl,
        key: key,
        productId: productId,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );

      if (cancelToken?.isCancelled == true) {
        _wipeMemoryCacheForProduct(key, productId);
        return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
      }

      if (glbBundle == null || glbBundle.runnableUri.isEmpty) {
        // Keep loading failure honest; wipe incomplete memory entry on error so retry works cleanly
        _wipeMemoryCacheForProduct(key, productId);
        return const FashnTryOnResult(
          isSuccess: false,
          errorMessage: 'Due to heavy server load, 3D avatar generation could not be completed. Please try again.',
        );
      }

      // 4. Atomic Commit to Memory + Local Disk + Supabase DB (only after full pipeline succeeds!)
      await _saveToMemoryAndPrefs(
        key: key,
        productId: productId,
        imageUrl: permanent2DUrl,
        remoteGlbUrl: glbBundle.remoteUrl,
        localFilePath: glbBundle.localFilePath,
      );

      await _persistToWardrobeItems(
        productId: productId,
        productName: effectiveTitle,
        productBrand: productBrand ?? 'Fitvisor Studio',
        productPrice: productPrice ?? '',
        productImage: garmentImagePath,
        category: category,
        tryOnImageUrl: permanent2DUrl,
        remoteGlbUrl: glbBundle.remoteUrl,
      );

      onGlbReady?.call(glbBundle.runnableUri);
      UserAvatarService.setLatestTryOn(glbUrl: glbBundle.runnableUri, imageUrl: permanent2DUrl);
      stopwatch.stop();

      return FashnTryOnResult(
        isSuccess: true,
        tryOnImageUrl: permanent2DUrl,
        glbModelUrl: glbBundle.runnableUri,
        remoteGlbUrl: glbBundle.remoteUrl,
        processingTimeSec: stopwatch.elapsedMilliseconds / 1000.0,
      );
    } catch (e) {
      stopwatch.stop();
      if (cancelToken?.isCancelled == true) {
        _wipeMemoryCacheForProduct(key, productId);
        return const FashnTryOnResult(isSuccess: false, isCancelled: true, errorMessage: 'Cancelled');
      }
      debugPrint('[FashnTryOnService] Pipeline exception: $e');
      return FashnTryOnResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  String? _lastFashnError;

  String _buildTailoringPrompt({
    required String category,
    required String productTitle,
    required double heightCm,
    required bool isMale,
  }) {
    final hCm = heightCm.clamp(140.0, 210.0).round();
    final normCat = _normalizeCategory('$category $productTitle');
    final genderWord = isMale ? 'man' : 'woman';

    if (normCat == 'one-pieces') {
      return 'Photorealistic high-fashion full-body studio portrait of the exact $genderWord from model_image standing straight on a clean pure white background. '
          'Keep the exact face, facial features, eyes, skin tone, hair, head size, and exact ${hCm}cm body height 100% identical to model_image - do not lengthen the body or alter the face. '
          'Skin texture on the face, neck, and chest must be completely smooth, clear, radiant, and youthful with zero wrinkles, zero creases, and zero artificial doll-like distortion. '
          'The model has firm, straight, squared athletic shoulders with level clavicles and chest held high - absolutely zero slouching, zero shoulder drooping, and zero drooping posture. '
          'Arms, wrists, and hands are sculpted with natural, tight athletic definition, held slightly away from the torso in a clean relaxed A-pose. '
          'Tailor the dress from product_image in an ultra-sleek, tight, body-contoured fit that sharply hugs the chest, sculpted waist, and hips conforming perfectly to an athletic, firm, toned female physique. '
          'The dress must be structured, firm, and tight to the body with zero oversized sagging, zero baggy loose fabric, and no wide bulging bell drape. '
          'Keep the skirt neatly tapered and proportioned with clean separation between the legs so both ankles and shoes are clearly visible. '
          'Both feet and shoes must be firmly planted flat on the floor in clean grounded posture.';
    }

    return 'Photorealistic high-fashion full-body studio portrait of the exact $genderWord from model_image standing straight on a clean pure white background. '
        'Keep the exact face, facial features, eyes, skin tone, hair, head size, and exact ${hCm}cm body height 100% identical to model_image - do not alter the face or stretch body proportions. '
        'Skin texture on the face, neck, and chest must be completely smooth, clear, and youthful with zero wrinkles, zero creases, and zero artificial distortion. '
        'The model has firm, straight, squared athletic shoulders with level clavicles and chest held high - absolutely zero slouching, zero drooping shoulders. '
        'Arms, wrists, and hands are sculpted with natural, tight athletic definition. '
        'Fit the garment from product_image in a sharp, tailored, form-fitting cut conforming tightly to the body with crisp realistic fabric texture, natural sharp folds, and athletic proportions. '
        'Zero oversized sagging, zero baggy excess fabric. '
        'Keep both legs, ankles, and shoes clearly visible and firmly planted flat on the floor.';
  }

  Future<String?> _runFashnTryOnStage({
    required String modelInput,
    required String garmentInput,
    required String garmentImagePath,
    required String category,
    required String productTitle,
    required double heightCm,
    required bool isMale,
    required bool allowFallbackRetry,
    TryOnCancellationToken? cancelToken,
    void Function(String message)? onProgress,
  }) async {
    _lastFashnError = null;
    final runUri = Uri.parse('$_baseUrl/run');

    final isFlatCutout = garmentImagePath.contains('product_') ||
        garmentImagePath.endsWith('.png') ||
        garmentImagePath.endsWith('.jpg');

    final tailoringPrompt = _buildTailoringPrompt(
      category: category,
      productTitle: productTitle,
      heightCm: heightCm,
      isMale: isMale,
    );

    // Primary high-fidelity 2K pipeline with explicit height/dress-length prompt
    Map<String, dynamic> maxPayload = {
      'model_name': 'tryon-max',
      'inputs': {
        'model_image': modelInput,
        'product_image': garmentInput,
        'prompt': tailoringPrompt,
        'resolution': '2k',
        'generation_mode': 'quality',
        'output_format': 'png',
      },
    };

    debugPrint('[FITVISOR-TRYON] Calling Fashn AI tryon-max (model: ${modelInput.startsWith('data:') ? 'base64 (${modelInput.length} chars)' : modelInput})...');
    var runResponse = await _postJsonWithClient(
      uri: runUri,
      headers: {'Authorization': 'Bearer $_apiKey'},
      body: maxPayload,
      timeout: const Duration(seconds: 60),
      cancelToken: cancelToken,
    );

    // Seamless fallback to v1.6 quality mode if tryon-max rejects schema or tier
    if (runResponse.statusCode != 200 &&
        (runResponse.statusCode == 400 ||
            runResponse.statusCode == 404 ||
            runResponse.statusCode == 422)) {
      debugPrint('[FITVISOR-TRYON] Primary schema returned ${runResponse.statusCode} (${runResponse.body}), trying quality fallback schema...');
      final v16Payload = {
        'model_name': 'tryon-v1.6',
        'inputs': {
          'model_image': modelInput,
          'garment_image': garmentInput,
          'category': _normalizeCategory('$category $productTitle'),
          'mode': 'quality',
          'garment_photo_type': isFlatCutout ? 'flat-lay' : 'auto',
          'segmentation_free': true,
          'output_format': 'png',
        },
      };
      runResponse = await _postJsonWithClient(
        uri: runUri,
        headers: {'Authorization': 'Bearer $_apiKey'},
        body: v16Payload,
        timeout: const Duration(seconds: 60),
        cancelToken: cancelToken,
      );
    }

    if (cancelToken?.isCancelled == true) return null;

    if (runResponse.statusCode != 200) {
      debugPrint('[FITVISOR-TRYON] Initial POST returned HTTP ${runResponse.statusCode}: ${runResponse.body}');
      if (allowFallbackRetry) {
        debugPrint('[FITVISOR-TRYON] Retrying with studio fallback model image...');
        final studioInput = await _loadStudioFallbackModelInput(isMale);
        if (studioInput != modelInput) {
          return _runFashnTryOnStage(
            modelInput: studioInput,
            garmentInput: garmentInput,
            garmentImagePath: garmentImagePath,
            category: category,
            productTitle: productTitle,
            heightCm: heightCm,
            isMale: isMale,
            allowFallbackRetry: false,
            cancelToken: cancelToken,
            onProgress: onProgress,
          );
        }
      }
      try {
        final errJson = jsonDecode(runResponse.body);
        _lastFashnError = (errJson['message'] ?? errJson['error'] ?? 'Fitting service unavailable').toString();
      } catch (_) {
        _lastFashnError = runResponse.statusCode == 599 ? runResponse.body : 'Request failed (HTTP ${runResponse.statusCode})';
      }
      return null;
    }

    final runJson = jsonDecode(runResponse.body) as Map<String, dynamic>;
    final predictionId = runJson['id'] as String?;
    if (predictionId == null || predictionId.isEmpty) {
      _lastFashnError = 'Invalid session ID returned';
      return null;
    }

    // Poll until completion (2K quality mode typically takes 18–45 seconds)
    final statusUri = Uri.parse('$_baseUrl/status/$predictionId');
    for (int attempt = 1; attempt <= 50; attempt++) {
      final proceeded = await _delayOrCancel(const Duration(milliseconds: 1500), cancelToken);
      if (!proceeded || cancelToken?.isCancelled == true) return null;

      onProgress?.call("Tailoring garment on your avatar (${(attempt * 1.5).round()}s)...");

      final pollRes = await _getWithClient(
        uri: statusUri,
        headers: {'Authorization': 'Bearer $_apiKey'},
        timeout: const Duration(seconds: 12),
        cancelToken: cancelToken,
      );

      if (cancelToken?.isCancelled == true) return null;
      if (pollRes == null || pollRes.statusCode != 200) continue;

      try {
        final statusJson = jsonDecode(pollRes.body) as Map<String, dynamic>;
        final status = statusJson['status'] as String? ?? '';
        if (status == 'completed') {
          final output = statusJson['output'];
          if (output is List && output.isNotEmpty) return output[0]?.toString();
          if (output is String) return output;
        } else if (status == 'failed') {
          final error = statusJson['error'];
          _lastFashnError = error is Map
              ? (error['message'] ?? 'Try-on processing failed').toString()
              : 'Try-on processing failed';
          if (allowFallbackRetry) {
            final studioInput = await _loadStudioFallbackModelInput(isMale);
            if (studioInput != modelInput) {
              return _runFashnTryOnStage(
                modelInput: studioInput,
                garmentInput: garmentInput,
                garmentImagePath: garmentImagePath,
                category: category,
                productTitle: productTitle,
                heightCm: heightCm,
                isMale: isMale,
                allowFallbackRetry: false,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            }
          }
          return null;
        }
      } catch (_) {}
    }

    _lastFashnError = 'Generation timed out. Please check your connection and try again.';
    return null;
  }

  Future<_GlbBundle?> _generateTripo3DModel(
    String imageUrl, {
    required String key,
    String? productId,
    TryOnCancellationToken? cancelToken,
    void Function(String message)? onProgress,
  }) async {
    final imageBytes = await _fetchImageBytes(imageUrl, cancelToken: cancelToken);
    if (cancelToken?.isCancelled == true || imageBytes == null || imageBytes.isEmpty) {
      return null;
    }

    onProgress?.call("Preparing 3D garment & body draping...");
    final isPng = imageUrl.toLowerCase().contains('.png');
    final fileToken = await _uploadImageToTripo(
      imageBytes,
      _tripoKey,
      isPng: isPng,
      cancelToken: cancelToken,
    );
    if (cancelToken?.isCancelled == true || fileToken == null || fileToken.isEmpty) {
      return null;
    }

    // ── STAGE 1: High-Detail 3D Mesh Reconstruction ──────────────────────────
    onProgress?.call("Reconstructing 3D body garment geometry...");
    final meshRes = await _postJsonWithClient(
      uri: Uri.parse('$_tripoBaseUrl/generation/image-to-model'),
      headers: {'Authorization': 'Bearer $_tripoKey'},
      body: {
        'input': fileToken,
        'model': 'v3.1-20260211',
        'texture': true,
        'pbr': true,
        'delight': true,
        'enable_image_autofix': false, // Preserve original face and natural skin; prevents AI face distortion and wrinkle artifacts
        'face_limit': 80000,
        'texture_quality': 'detailed',
        'geometry_quality': 'detailed',
        'texture_alignment': 'original_image',
        'auto_size': true,
      },
      timeout: const Duration(seconds: 25),
      cancelToken: cancelToken,
    );

    if (cancelToken?.isCancelled == true || meshRes.statusCode != 200) return null;
    final meshJson = jsonDecode(meshRes.body) as Map<String, dynamic>;
    final meshTaskId = meshJson['data']?['task_id'] as String?;
    if (meshTaskId == null || meshTaskId.isEmpty) return null;

    final rawMeshGlb = await _pollTripoTask(
      meshTaskId,
      stageLabel: "Reconstructing 3D body garment geometry",
      maxPolls: 80,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );
    if (cancelToken?.isCancelled == true || rawMeshGlb == null || rawMeshGlb.isEmpty) {
      return null;
    }

    String finalRemoteGlb = rawMeshGlb;

    // ── STAGE 2: Humanoid Skeletal Auto-Rigging ──────────────────────────────
    onProgress?.call("Fitting 3D avatar skeleton & joints...");
    final rigRes = await _postJsonWithClient(
      uri: Uri.parse('$_tripoBaseUrl/animations/rig'),
      headers: {'Authorization': 'Bearer $_tripoKey'},
      body: {
        'input': meshTaskId,
        'model': 'v3.0-20260909',
        'rig_type': 'biped',
        'spec': 'mixamo',
        'out_format': 'glb',
      },
      timeout: const Duration(seconds: 25),
      cancelToken: cancelToken,
    );

    if (cancelToken?.isCancelled == true) return null;
    if (rigRes.statusCode == 200) {
      final rigJson = jsonDecode(rigRes.body) as Map<String, dynamic>;
      final rigTaskId = rigJson['data']?['task_id'] as String?;
      if (rigTaskId != null && rigTaskId.isNotEmpty) {
        final riggedGlb = await _pollTripoTask(
          rigTaskId,
          stageLabel: "Fitting 3D avatar skeleton & joints",
          maxPolls: 60,
          cancelToken: cancelToken,
          onProgress: onProgress,
        );
        if (cancelToken?.isCancelled == true) return null;

        if (riggedGlb != null && riggedGlb.isNotEmpty) {
          finalRemoteGlb = riggedGlb;

          // ── STAGE 3: Runway Catwalk Motion ─────────────────────────────────
          onProgress?.call("Applying runway catwalk motion...");
          final retargetRes = await _postJsonWithClient(
            uri: Uri.parse('$_tripoBaseUrl/animations/retarget'),
            headers: {'Authorization': 'Bearer $_tripoKey'},
            body: {
              'original_model_task_id': rigTaskId,
              'input': rigTaskId,
              'animations': [
                'preset:idle',
                'preset:walk',
              ],
              'animate_in_place': true,
              'export_with_geometry': true,
              'out_format': 'glb',
            },
            timeout: const Duration(seconds: 25),
            cancelToken: cancelToken,
          );

          if (cancelToken?.isCancelled == true) return null;
          if (retargetRes.statusCode == 200) {
            final retargetJson = jsonDecode(retargetRes.body) as Map<String, dynamic>;
            final retargetTaskId = retargetJson['data']?['task_id'] as String?;
            if (retargetTaskId != null && retargetTaskId.isNotEmpty) {
              final animatedGlb = await _pollTripoTask(
                retargetTaskId,
                stageLabel: "Syncing runway catwalk motion",
                maxPolls: 60,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
              if (cancelToken?.isCancelled == true) return null;
              if (animatedGlb != null && animatedGlb.isNotEmpty) {
                finalRemoteGlb = animatedGlb;
              }
            }
          }
        }
      }
    }

    // ── STAGE 4: Download Once -> Save Locally + Upload Permanently to Cloud ──
    onProgress?.call("Saving 3D garment avatar to your wardrobe...");
    final glbBytes = await _fetchBinaryBytes(
      finalRemoteGlb,
      timeout: const Duration(seconds: 50),
      cancelToken: cancelToken,
    );
    if (cancelToken?.isCancelled == true) return null;

    String? localFilePath;
    String permanentRemoteUrl = '';

    if (glbBytes != null && glbBytes.length > 10000) {
      localFilePath = await _writeLocalGlbFile(
        bytes: glbBytes,
        slug: _safeSlug('${_userScope()}_${productId ?? key}'),
      );

      final uploadedGlbUrl = await _uploadBytesToSupabaseStorage(
        bytes: glbBytes,
        fileName: 'tryon_${DateTime.now().millisecondsSinceEpoch}.glb',
        contentType: 'model/gltf-binary',
        cancelToken: cancelToken,
      );
      if (uploadedGlbUrl != null && uploadedGlbUrl.isNotEmpty) {
        permanentRemoteUrl = uploadedGlbUrl;
      }
    }

    if (cancelToken?.isCancelled == true) return null;

    // Prefer public HTTPS CDN URL so Android WebView ModelViewer has zero CORS/file access restrictions
    final runnableUri = permanentRemoteUrl.isNotEmpty
        ? permanentRemoteUrl
        : (finalRemoteGlb.isNotEmpty
            ? finalRemoteGlb
            : (localFilePath != null ? Uri.file(localFilePath).toString() : ''));

    if (runnableUri.isEmpty) return null;

    debugPrint('[FITVISOR-TRYON] 3D Model ready for ModelViewer: $runnableUri');

    return _GlbBundle(
      runnableUri: runnableUri,
      remoteUrl: permanentRemoteUrl.isNotEmpty ? permanentRemoteUrl : runnableUri,
      localFilePath: localFilePath,
    );
  }

  /// Shared Tripo task poller with cancellation & transient network tolerance.
  Future<String?> _pollTripoTask(
    String taskId, {
    required String stageLabel,
    required int maxPolls,
    TryOnCancellationToken? cancelToken,
    void Function(String message)? onProgress,
  }) async {
    final uri = Uri.parse('$_tripoBaseUrl/tasks/$taskId');
    for (int i = 1; i <= maxPolls; i++) {
      final proceeded = await _delayOrCancel(const Duration(seconds: 3), cancelToken);
      if (!proceeded || cancelToken?.isCancelled == true) return null;

      final res = await _getWithClient(
        uri: uri,
        headers: {'Authorization': 'Bearer $_tripoKey'},
        timeout: const Duration(seconds: 15),
        cancelToken: cancelToken,
      );
      if (cancelToken?.isCancelled == true) return null;
      if (res == null || res.statusCode != 200) continue;

      try {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        final status = data?['status'] as String? ?? '';
        final progress = data?['progress'] ?? 0;
        onProgress?.call("$stageLabel ($progress%)...");

        if (status == 'success') {
          final output = data?['output'] as Map<String, dynamic>?;
          return output?['model_url'] as String? ??
              output?['pbr_model'] as String? ??
              output?['model'] as String?;
        }
        if (status == 'failed' || status == 'cancelled') {
          debugPrint('[3D Pipeline] Task $taskId ended with status=$status');
          return null;
        }
      } catch (_) {}
    }
    return null;
  }

  // ── STORAGE, CACHE & SUPABASE DB PERSISTENCE HELPERS ─────────────────────────

  Future<String?> _ensureLocalGlbCached({
    required String remoteUrl,
    required String scopedCombo,
    String? scopedProd,
    TryOnCancellationToken? cancelToken,
  }) async {
    final bytes = await _fetchBinaryBytes(
      remoteUrl,
      timeout: const Duration(seconds: 40),
      cancelToken: cancelToken,
    );
    if (cancelToken?.isCancelled == true || bytes == null || bytes.length < 10000) {
      return null;
    }
    final savedPath = await _writeLocalGlbFile(
      bytes: bytes,
      slug: _safeSlug(scopedProd ?? scopedCombo),
    );
    if (savedPath == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tryon_local_$scopedCombo', savedPath);
      if (scopedProd != null) await prefs.setString('tryon_local_$scopedProd', savedPath);
    } catch (_) {}
    return Uri.file(savedPath).toString();
  }

  Future<String?> _writeLocalGlbFile({required List<int> bytes, required String slug}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tryon_v2_$slug.glb');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('[FashnTryOnService] Failed saving local GLB: $e');
      return null;
    }
  }

  Future<void> _saveToMemoryAndPrefs({
    required String key,
    String? productId,
    String? imageUrl,
    required String remoteGlbUrl,
    String? localFilePath,
  }) async {
    final uid = _userScope();
    final scopedCombo = '${uid}_v2_$key';
    final scopedProd = (productId != null && productId.isNotEmpty) ? '${uid}_v2_$productId' : null;
    final runnableGlb = (localFilePath != null && File(localFilePath).existsSync())
        ? Uri.file(localFilePath).toString()
        : remoteGlbUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      _tryOnCache[_scopedKey(key)] = imageUrl;
      if (productId != null && productId.isNotEmpty) {
        _tryOnCache[_scopedKey(productId)] = imageUrl;
      }
    }
    _tryOnGlbCache[_scopedKey(key)] = remoteGlbUrl;
    if (productId != null && productId.isNotEmpty) {
      _tryOnGlbCache[_scopedKey(productId)] = remoteGlbUrl;
    }
    if (localFilePath != null && localFilePath.isNotEmpty) {
      _localGlbFileCache[_scopedKey(key)] = runnableGlb;
      if (productId != null && productId.isNotEmpty) {
        _localGlbFileCache[_scopedKey(productId)] = runnableGlb;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await prefs.setString('tryon_img_$scopedCombo', imageUrl);
        if (scopedProd != null) await prefs.setString('tryon_img_$scopedProd', imageUrl);
      }
      if (remoteGlbUrl.startsWith('http')) {
        await prefs.setString('tryon_glb_$scopedCombo', remoteGlbUrl);
        if (scopedProd != null) await prefs.setString('tryon_glb_$scopedProd', remoteGlbUrl);
      }
      if (localFilePath != null && localFilePath.isNotEmpty) {
        await prefs.setString('tryon_local_$scopedCombo', localFilePath);
        if (scopedProd != null) await prefs.setString('tryon_local_$scopedProd', localFilePath);
      }
    } catch (_) {}
  }

  void _wipeMemoryCacheForProduct(String key, String? productId) {
    _tryOnCache.remove(_scopedKey(key));
    _tryOnGlbCache.remove(_scopedKey(key));
    _localGlbFileCache.remove(_scopedKey(key));
    if (productId != null && productId.isNotEmpty) {
      _tryOnCache.remove(_scopedKey(productId));
      _tryOnGlbCache.remove(_scopedKey(productId));
      _localGlbFileCache.remove(_scopedKey(productId));
    }
  }

  /// Saves or updates the complete 3D try-on inside Supabase `wardrobe_items`.
  /// Uses explicit select -> update/insert (never broken ON CONFLICT).
  Future<void> _persistToWardrobeItems({
    required String? productId,
    required String productName,
    required String productBrand,
    required String productPrice,
    required String productImage,
    required String category,
    required String tryOnImageUrl,
    required String remoteGlbUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || productId == null || productId.isEmpty) return;
    if (!remoteGlbUrl.startsWith('http')) return;

    try {
      final client = Supabase.instance.client;
      final existingRows = await client
          .from('wardrobe_items')
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .limit(1);

      final updateFields = <String, dynamic>{
        'tryon_image_url': tryOnImageUrl,
        'glb_model_url': remoteGlbUrl,
        'is_worn_in_3d': true,
      };

      if (existingRows.isNotEmpty) {
        final rowId = existingRows.first['id'];
        await client.from('wardrobe_items').update(updateFields).eq('id', rowId);
      } else {
        await client.from('wardrobe_items').insert({
          'user_id': user.id,
          'product_id': productId,
          'product_name': productName,
          'product_brand': productBrand,
          'product_price': productPrice,
          'product_image': productImage,
          'category': category,
          ...updateFields,
        });
      }
      debugPrint('[FashnTryOnService] Persisted 3D try-on permanently to Supabase wardrobe_items for product=$productId');
    } catch (saveErr) {
      debugPrint('[FashnTryOnService] Supabase wardrobe_items persist note: $saveErr');
    }
  }

  Future<String?> _uploadBytesToSupabaseStorage({
    required List<int> bytes,
    required String fileName,
    required String contentType,
    TryOnCancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 25);
    cancelToken?.registerClient(client);
    try {
      final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      final upUri = Uri.parse('$_supabaseUrl/storage/v1/object/avatars/$fileName');
      final upReq = await client.postUrl(upUri);
      upReq.headers.set('apikey', serviceKey);
      upReq.headers.set('Authorization', 'Bearer $serviceKey');
      upReq.headers.set('Content-Type', contentType);
      upReq.headers.set('x-upsert', 'true');
      upReq.add(bytes);
      final upRes = await upReq.close().timeout(const Duration(seconds: 40));
      if (upRes.statusCode == 200 || upRes.statusCode == 201) {
        return '$_supabaseUrl/storage/v1/object/public/avatars/$fileName';
      }
      final body = await upRes.transform(utf8.decoder).join();
      debugPrint('[Storage] Upload failed HTTP ${upRes.statusCode}: $body');
      return null;
    } catch (e) {
      debugPrint('[Storage] Upload exception: $e');
      return null;
    } finally {
      cancelToken?.unregisterClient(client);
      client.close();
    }
  }

  // ── LOW-LEVEL HTTP & INPUT HELPERS ──────────────────────────────────────────

  Future<String> _resolveModelImageInput({
    File? userAvatarFile,
    String? userAvatarUrl,
    required bool isMale,
  }) async {
    // 1. If remote URL is an image (NOT a .glb model!), use directly
    if (userAvatarUrl != null &&
        userAvatarUrl.startsWith('http') &&
        !userAvatarUrl.endsWith('.glb')) {
      debugPrint('[FITVISOR-TRYON] Using user profile avatar URL: $userAvatarUrl');
      return userAvatarUrl;
    }

    // 2. If explicit valid image file is provided and exists, upload to Supabase for fast CDN URL
    if (userAvatarFile != null && await userAvatarFile.exists()) {
      try {
        final bytes = await userAvatarFile.readAsBytes();
        if (bytes.length > 1000) {
          debugPrint('[FITVISOR-TRYON] Uploading user scan photo to Supabase storage (${bytes.length} bytes)...');
          final uploaded = await _uploadBytesToSupabaseStorage(
            bytes: bytes,
            fileName: 'avatar_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: 'image/jpeg',
          );
          if (uploaded != null && uploaded.isNotEmpty) {
            debugPrint('[FITVISOR-TRYON] Uploaded user scan photo -> $uploaded');
            return uploaded;
          }
          return 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }
      } catch (e) {
        debugPrint('[FITVISOR-TRYON] Error reading userAvatarFile: $e');
      }
    }

    // 3. If in-memory avatar file exists
    final activeFile = UserAvatarService.avatarNotifier.value;
    if (activeFile != null && await activeFile.exists()) {
      try {
        final bytes = await activeFile.readAsBytes();
        if (bytes.length > 1000) {
          final uploaded = await _uploadBytesToSupabaseStorage(
            bytes: bytes,
            fileName: 'avatar_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: 'image/jpeg',
          );
          if (uploaded != null && uploaded.isNotEmpty) return uploaded;
          return 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }
      } catch (_) {}
    }

    // 4. Try local disk user avatar file
    try {
      final dir = await getApplicationDocumentsDirectory();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final f = File('${dir.path}/user_avatar_${user.id}.jpg');
        if (await f.exists()) {
          final bytes = await f.readAsBytes();
          if (bytes.length > 1000) {
            final uploaded = await _uploadBytesToSupabaseStorage(
              bytes: bytes,
              fileName: 'avatar_scan_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: 'image/jpeg',
            );
            if (uploaded != null && uploaded.isNotEmpty) return uploaded;
            return 'data:image/jpeg;base64,${base64Encode(bytes)}';
          }
        }
      }
    } catch (_) {}

    // 5. Permanent public clean studio photo from Supabase
    const cleanPublicUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/user_scan_front_clean.jpg';
    debugPrint('[FITVISOR-TRYON] Using high-res clean studio URL: $cleanPublicUrl');
    return cleanPublicUrl;
  }

  Future<String> _loadStudioFallbackModelInput(bool isMale) async {
    final assetPath = isMale ? 'assets/images/avatar_male_model.jpg' : 'assets/images/scan_front_pose.jpg';
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  Future<String> _resolveImageInput(String imagePath) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      debugPrint('[FITVISOR-TRYON] Garment image URL: $imagePath');
      return imagePath;
    }
    try {
      final byteData = await rootBundle.load(imagePath);
      final bytes = byteData.buffer.asUint8List();
      final mime = imagePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final ext = imagePath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';

      debugPrint('[FITVISOR-TRYON] Uploading local garment asset ($imagePath, ${bytes.length} bytes) to Supabase...');
      final uploaded = await _uploadBytesToSupabaseStorage(
        bytes: bytes,
        fileName: 'garment_asset_${_safeSlug(imagePath)}.$ext',
        contentType: mime,
      );
      if (uploaded != null && uploaded.isNotEmpty) {
        debugPrint('[FITVISOR-TRYON] Uploaded garment asset -> $uploaded');
        return uploaded;
      }
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('[FITVISOR-TRYON] Failed to load asset $imagePath: $e');
      return imagePath;
    }
  }

  Future<List<int>?> _fetchImageBytes(String imageUrl, {TryOnCancellationToken? cancelToken}) async {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return _fetchBinaryBytes(imageUrl, timeout: const Duration(seconds: 25), cancelToken: cancelToken);
    } else if (imageUrl.startsWith('data:image')) {
      final comma = imageUrl.indexOf(',');
      if (comma != -1) return base64Decode(imageUrl.substring(comma + 1));
    } else {
      try {
        final byteData = await rootBundle.load(imageUrl);
        return byteData.buffer.asUint8List();
      } catch (_) {}
    }
    return null;
  }

  Future<List<int>?> _fetchBinaryBytes(
    String url, {
    required Duration timeout,
    TryOnCancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    cancelToken?.registerClient(client);
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close().timeout(timeout);
      if (res.statusCode == 200) {
        return await consolidateHttpClientResponseBytes(res);
      }
    } catch (e) {
      debugPrint('[HTTP] Download failed ($url): $e');
    } finally {
      cancelToken?.unregisterClient(client);
      client.close();
    }
    return null;
  }

  Future<String?> _uploadImageToTripo(
    List<int> imageBytes,
    String tripoKey, {
    required bool isPng,
    TryOnCancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    cancelToken?.registerClient(client);
    try {
      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      final uploadUri = Uri.parse('$_tripoBaseUrl/files');
      final req = await client.postUrl(uploadUri);
      req.headers.set('Authorization', 'Bearer $tripoKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');

      final ext = isPng ? 'png' : 'jpg';
      final mime = isPng ? 'image/png' : 'image/jpeg';
      final header = utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="file"; filename="tryon.$ext"\r\n'
        'Content-Type: $mime\r\n\r\n',
      );
      final footer = utf8.encode('\r\n--$boundary--\r\n');

      req.contentLength = header.length + imageBytes.length + footer.length;
      req.add(header);
      req.add(imageBytes);
      req.add(footer);

      final res = await req.close().timeout(const Duration(seconds: 30));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['code'] == 0 && json['data'] != null) {
        return (json['data']?['file_token'] ?? json['data']?['image_token']) as String?;
      }
      debugPrint('[3D Pipeline] Upload failed: $body');
      return null;
    } catch (e) {
      debugPrint('[3D Pipeline] Upload error: $e');
      return null;
    } finally {
      cancelToken?.unregisterClient(client);
      client.close();
    }
  }

  Future<_HttpJsonResponse> _postJsonWithClient({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    required Duration timeout,
    TryOnCancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return const _HttpJsonResponse(statusCode: 499, body: 'Cancelled');
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 45);
    cancelToken?.registerClient(client);
    try {
      debugPrint('[FITVISOR-HTTP] POST $uri (timeout: ${timeout.inSeconds}s)...');
      final req = await client.postUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final encodedPayload = utf8.encode(jsonEncode(body));
      req.contentLength = encodedPayload.length;
      req.add(encodedPayload);
      final res = await req.close().timeout(timeout);
      final resBody = await res.transform(utf8.decoder).join();
      debugPrint('[FITVISOR-HTTP] POST $uri -> HTTP ${res.statusCode}');
      if (res.statusCode != 200) {
        debugPrint('[FITVISOR-HTTP] Response Body: $resBody');
      }
      return _HttpJsonResponse(statusCode: res.statusCode, body: resBody);
    } catch (e, stack) {
      debugPrint('[FITVISOR-HTTP-ERROR] POST $uri failed: $e');
      debugPrint('[FITVISOR-HTTP-STACK] $stack');
      return _HttpJsonResponse(statusCode: 599, body: 'Network error: $e');
    } finally {
      cancelToken?.unregisterClient(client);
      client.close();
    }
  }

  Future<_HttpJsonResponse?> _getWithClient({
    required Uri uri,
    required Map<String, String> headers,
    required Duration timeout,
    TryOnCancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    cancelToken?.registerClient(client);
    try {
      final req = await client.getUrl(uri);
      headers.forEach((k, v) => req.headers.set(k, v));
      final res = await req.close().timeout(timeout);
      final resBody = await res.transform(utf8.decoder).join();
      return _HttpJsonResponse(statusCode: res.statusCode, body: resBody);
    } catch (_) {
      return null;
    } finally {
      cancelToken?.unregisterClient(client);
      client.close();
    }
  }

  /// Waits for [duration], or resolves with `false` the exact millisecond [token] cancels.
  Future<bool> _delayOrCancel(Duration duration, TryOnCancellationToken? token) async {
    if (token == null) {
      await Future.delayed(duration);
      return true;
    }
    if (token.isCancelled) return false;
    final completer = Completer<bool>();
    late final Timer timer;
    void onCancel() {
      timer.cancel();
      if (!completer.isCompleted) completer.complete(false);
    }
    token.addListener(onCancel);
    timer = Timer(duration, () {
      token.removeListener(onCancel);
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }

  String _normalizeCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('pant') ||
        c.contains('trouser') ||
        c.contains('jean') ||
        c.contains('skirt') ||
        c.contains('short') ||
        c.contains('jogger')) {
      return 'bottoms';
    }
    if (c.contains('dress') ||
        c.contains('robe') ||
        c.contains('gown') ||
        c.contains('soirée') ||
        c.contains('soiree') ||
        c.contains('combinaison') ||
        c.contains('jumpsuit') ||
        c.contains('suit') ||
        c.contains('costume')) {
      return 'one-pieces';
    }
    return 'tops';
  }
}

class _GlbBundle {
  final String runnableUri;
  final String remoteUrl;
  final String? localFilePath;

  const _GlbBundle({
    required this.runnableUri,
    required this.remoteUrl,
    this.localFilePath,
  });
}

class _HttpJsonResponse {
  final int statusCode;
  final String body;

  const _HttpJsonResponse({required this.statusCode, required this.body});
}
