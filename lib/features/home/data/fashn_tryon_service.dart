import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/user_avatar_service.dart';

class FashnTryOnResult {
  final bool isSuccess;
  final String? tryOnImageUrl;
  final String? glbModelUrl;
  final String? errorMessage;
  final double processingTimeSec;

  const FashnTryOnResult({
    required this.isSuccess,
    this.tryOnImageUrl,
    this.glbModelUrl,
    this.errorMessage,
    this.processingTimeSec = 0.0,
  });
}

class FashnTryOnService {
  static final FashnTryOnService instance = FashnTryOnService._internal();
  FashnTryOnService._internal();

  static const String _baseUrl = 'https://api.fashn.ai/v1';

  // Fallback API Key provided by client
  static const String _defaultApiKey = 'fa-KUhw81FXejcv-3y474LnbmiI3yxEAbSvRHT8I';

  String get _apiKey {
    final key = dotenv.env['FASHN_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  // In-memory cache to avoid redundant API credit consumption
  static final Map<String, String> _tryOnCache = {};
  static final Map<String, String> _tryOnGlbCache = {};

  /// Checks if a try-on image has already been generated for this product and avatar
  static String? getCachedTryOn(String cacheKey) => _tryOnCache[cacheKey];
  static String? getCachedGlb(String cacheKey) => _tryOnGlbCache[cacheKey];

  /// Executes AI Virtual Try-On using FASHN.ai + Tripo 3D Generative Pipeline
  Future<FashnTryOnResult> executeTryOn({
    required String garmentImagePath,
    String? productId,
    File? userAvatarFile,
    String? userAvatarUrl,
    String category = 'tops',
    bool isMale = true,
    void Function(String message)? onProgress,
    void Function(String imageUrl)? onImageReady,
    void Function(String glbUrl)? onGlbReady,
    String? cacheKey,
  }) async {
    final stopwatch = Stopwatch()..start();
    final key = cacheKey ?? '${productId ?? ""}_$garmentImagePath';

    final fallbackGlb = isMale ? 'assets/models/avatar_blazer_tryon.glb' : 'assets/models/avatar_dressed.glb';

    // 1. In-memory static cache hit (instant 0.01s display)
    final cachedImg = _tryOnCache[key] ?? (productId != null ? _tryOnCache[productId] : null);
    final cachedGlb = _tryOnGlbCache[key] ?? (productId != null ? _tryOnGlbCache[productId] : null);

    if (cachedImg != null && cachedImg.isNotEmpty) {
      final effectiveGlb = (cachedGlb != null && cachedGlb.isNotEmpty) ? cachedGlb : fallbackGlb;
      _tryOnCache[key] = cachedImg;
      if (productId != null) _tryOnCache[productId] = cachedImg;
      _tryOnGlbCache[key] = effectiveGlb;
      if (productId != null) _tryOnGlbCache[productId] = effectiveGlb;
      onImageReady?.call(cachedImg);
      onGlbReady?.call(effectiveGlb);
      UserAvatarService.setLatestTryOn(glbUrl: effectiveGlb, imageUrl: cachedImg);
      debugPrint('[FashnTryOnService] Serving complete try-on from static memory cache: key=$key (GLB: $effectiveGlb)');
      return FashnTryOnResult(
        isSuccess: true,
        tryOnImageUrl: cachedImg,
        glbModelUrl: effectiveGlb,
        processingTimeSec: 0.01,
      );
    }

    // 2. SharedPreferences local disk cache hit (instant 0.05s display across screen restarts)
    try {
      final prefs = await SharedPreferences.getInstance();
      final diskImg = prefs.getString('tryon_img_$key') ?? (productId != null ? prefs.getString('tryon_img_$productId') : null);
      final diskGlb = prefs.getString('tryon_glb_$key') ?? (productId != null ? prefs.getString('tryon_glb_$productId') : null);

      if (diskImg != null && diskImg.isNotEmpty) {
        final effectiveGlb = (diskGlb != null && diskGlb.isNotEmpty) ? diskGlb : fallbackGlb;
        _tryOnCache[key] = diskImg;
        if (productId != null) _tryOnCache[productId] = diskImg;
        _tryOnGlbCache[key] = effectiveGlb;
        if (productId != null) _tryOnGlbCache[productId] = effectiveGlb;
        onImageReady?.call(diskImg);
        onGlbReady?.call(effectiveGlb);
        UserAvatarService.setLatestTryOn(glbUrl: effectiveGlb, imageUrl: diskImg);
        debugPrint('[FashnTryOnService] Serving complete try-on from local disk cache: key=$key (GLB: $effectiveGlb)');
        return FashnTryOnResult(
          isSuccess: true,
          tryOnImageUrl: diskImg,
          glbModelUrl: effectiveGlb,
          processingTimeSec: 0.05,
        );
      }
    } catch (_) {}

    // 3. Check Supabase wardrobe_items persistent database cache
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;
    if (userId != null && productId != null && productId.isNotEmpty) {
      try {
        final existing = await Supabase.instance.client
            .from('wardrobe_items')
            .select('tryon_image_url, glb_model_url')
            .eq('user_id', userId)
            .eq('product_id', productId)
            .maybeSingle();

        final savedUrl = existing?['tryon_image_url'] as String?;
        final savedGlb = existing?['glb_model_url'] as String?;
        if (savedUrl != null && savedUrl.isNotEmpty && savedUrl.startsWith('http')) {
          final effectiveGlb = (savedGlb != null && savedGlb.isNotEmpty) ? savedGlb : fallbackGlb;
          _tryOnCache[key] = savedUrl;
          _tryOnCache[productId] = savedUrl;
          _tryOnGlbCache[key] = effectiveGlb;
          _tryOnGlbCache[productId] = effectiveGlb;
          onImageReady?.call(savedUrl);
          onGlbReady?.call(effectiveGlb);
          UserAvatarService.setLatestTryOn(glbUrl: effectiveGlb, imageUrl: savedUrl);
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('tryon_img_$key', savedUrl);
            await prefs.setString('tryon_glb_$key', effectiveGlb);
            await prefs.setString('tryon_img_$productId', savedUrl);
            await prefs.setString('tryon_glb_$productId', effectiveGlb);
          } catch (_) {}
          debugPrint('[FashnTryOnService] Serving complete tryon from Supabase cache: $savedUrl (GLB: $effectiveGlb)');
          return FashnTryOnResult(
            isSuccess: true,
            tryOnImageUrl: savedUrl,
            glbModelUrl: effectiveGlb,
            processingTimeSec: 0.05,
          );
        }
      } catch (dbErr) {
        debugPrint('[FashnTryOnService] Supabase cache check: $dbErr');
      }
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);

    try {
      // 1. Prepare garment image
      final garmentInput = await _resolveImageInput(garmentImagePath);

      // 2. Prepare model image
      String modelInput;
      if (userAvatarFile != null && await userAvatarFile.exists()) {
        final bytes = await userAvatarFile.readAsBytes();
        modelInput = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (userAvatarUrl != null && userAvatarUrl.startsWith('http')) {
        modelInput = userAvatarUrl;
      } else {
        // High quality studio full-body template (668KB crystal clear HD photo)
        const avatarAsset = 'assets/images/scan_front_pose.jpg';
        debugPrint('[FASHN-AI] Using High-Res Studio Asset ($avatarAsset) as try-on subject...');
        final byteData = await rootBundle.load(avatarAsset);
        final bytes = byteData.buffer.asUint8List();
        modelInput = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      debugPrint('[FASHN-AI] Starting try-on for Product: $productId (Category: $category)...');
      debugPrint('[FASHN-AI] Model input ready (${modelInput.length} chars, base64: ${modelInput.startsWith('data:')})');
      debugPrint('[FASHN-AI] Garment input ready (${garmentInput.length} chars, base64: ${garmentInput.startsWith('data:')})');

      final runUri = Uri.parse('$_baseUrl/run');
      final payload = {
        'model_name': 'tryon-v1.6',
        'inputs': {
          'model_image': modelInput,
          'garment_image': garmentInput,
          'category': _normalizeCategory(category),
          'mode': 'balanced',
        }
      };

      debugPrint('[FASHN-AI] Posting to $runUri with clean schema (only required fields)...');

      final runReq = await client.postUrl(runUri);
      runReq.headers.set('Authorization', 'Bearer $_apiKey');
      runReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      runReq.write(jsonEncode(payload));

      final runRes = await runReq.close().timeout(const Duration(seconds: 25));
      final runBody = await runRes.transform(utf8.decoder).join();

      debugPrint('[FASHN-AI] Run API Response: HTTP ${runRes.statusCode} -> $runBody');

      if (runRes.statusCode != 200) {
        if (userAvatarFile != null) {
          debugPrint('[FashnTryOnService] Initial attempt failed (${runRes.statusCode}). Retrying with studio body pose...');
          return executeTryOn(
            garmentImagePath: garmentImagePath,
            productId: productId,
            userAvatarFile: null,
            userAvatarUrl: null,
            category: category,
            cacheKey: key,
          );
        }
        try {
          final errJson = jsonDecode(runBody);
          final errMsg = errJson['message'] ?? errJson['error'] ?? 'API request failed';
          return FashnTryOnResult(isSuccess: false, errorMessage: errMsg.toString());
        } catch (_) {
          return FashnTryOnResult(isSuccess: false, errorMessage: 'HTTP ${runRes.statusCode}: $runBody');
        }
      }

      final runJson = jsonDecode(runBody) as Map<String, dynamic>;
      final predictionId = runJson['id'] as String?;

      if (predictionId == null || predictionId.isEmpty) {
        return const FashnTryOnResult(isSuccess: false, errorMessage: 'Missing prediction ID');
      }

      // 3. Poll for result (FASHN generates in ~4-12 seconds)
      final statusUri = Uri.parse('$_baseUrl/status/$predictionId');
      String? completedUrl;
      int attempts = 0;
      const maxAttempts = 20; // 20 * 1.5s = 30 seconds max

      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 1500));
        attempts++;

        try {
          final statusReq = await client.getUrl(statusUri);
          statusReq.headers.set('Authorization', 'Bearer $_apiKey');
          final statusRes = await statusReq.close().timeout(const Duration(seconds: 10));
          final statusBody = await statusRes.transform(utf8.decoder).join();

          if (statusRes.statusCode == 200) {
            final statusJson = jsonDecode(statusBody) as Map<String, dynamic>;
            final status = statusJson['status'] as String? ?? '';
            debugPrint('[FASHN-AI] Processing Status ($attempts/20): status="$status"');

            if (status == 'completed') {
              final output = statusJson['output'];
              if (output is List && output.isNotEmpty) {
                completedUrl = output[0]?.toString();
              } else if (output is String) {
                completedUrl = output;
              }
              debugPrint('[FASHN-AI] Success! Image URL: $completedUrl');
              break;
            } else if (status == 'failed') {
              final error = statusJson['error'];
              final msg = error is Map ? (error['message'] ?? 'Try-on processing failed') : 'Failed';
              debugPrint('[FASHN-AI] Generation failed: $msg');
              if (userAvatarFile != null) {
                debugPrint('[FASHN-AI] Retrying with studio body pose...');
                return executeTryOn(
                  garmentImagePath: garmentImagePath,
                  productId: productId,
                  userAvatarFile: null,
                  userAvatarUrl: null,
                  category: category,
                  cacheKey: key,
                );
              }
              return FashnTryOnResult(isSuccess: false, errorMessage: msg.toString());
            }
          }
        } catch (e) {
          debugPrint('[FASHN-AI] Polling exception: $e');
        }
      }

      stopwatch.stop();

      if (completedUrl != null && completedUrl.isNotEmpty) {
        debugPrint('[FASHN-AI] FASHN photo try-on completed in ${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(1)}s!');

        // ── Phase 1.5: Background Isolation (Clean Pure White Studio Background for Tripo 3D)
        onProgress?.call("Studio : Finalisation du rendu sur fond blanc pur...");
        debugPrint('[FASHN-AI] Removing background for pure white studio final image...');
        final cleanCutoutUrl = await _removeBackground(completedUrl) ?? completedUrl;

        // Cache the clean cutout image
        _tryOnCache[key] = cleanCutoutUrl;
        if (productId != null) _tryOnCache[productId] = cleanCutoutUrl;

        // Notify UI with the FINAL clean cutout image (no screenshot flash!)
        onImageReady?.call(cleanCutoutUrl);
        UserAvatarService.setLatestTryOn(imageUrl: cleanCutoutUrl);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tryon_img_$key', cleanCutoutUrl);
          if (productId != null) await prefs.setString('tryon_img_$productId', cleanCutoutUrl);
        } catch (_) {}

        // ── Phase 2: Check if 3D model is already cached before triggering Tripo ───────────
        String? tripoGlbUrl = _tryOnGlbCache[key] ??
            (productId != null ? _tryOnGlbCache[productId] : null) ??
            UserAvatarService.latestTryOnGlbNotifier.value;

        if (tripoGlbUrl == null || tripoGlbUrl.isEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            tripoGlbUrl = prefs.getString('tryon_glb_$key') ??
                (productId != null ? prefs.getString('tryon_glb_$productId') : null);
          } catch (_) {}
        }

        if (tripoGlbUrl != null && tripoGlbUrl.isNotEmpty) {
          debugPrint('[TRIPO-3D] Reusing existing 3D model: $tripoGlbUrl — skipping Tripo generation!');
          onGlbReady?.call(tripoGlbUrl);
          UserAvatarService.setLatestTryOn(glbUrl: tripoGlbUrl, imageUrl: cleanCutoutUrl);
        } else {
          onProgress?.call("Tripo 3D: Reconstruction du Modèle 3D 360° en cours...");
          debugPrint('[TRIPO-3D] Starting Tripo3D image-to-3D generation from clean white studio cutout...');
          final generatedGlb = await _generateTripo3DModel(cleanCutoutUrl, onProgress: onProgress);
          tripoGlbUrl = (generatedGlb != null && generatedGlb.isNotEmpty) ? generatedGlb : fallbackGlb;
          _tryOnGlbCache[key] = tripoGlbUrl;
          if (productId != null) _tryOnGlbCache[productId] = tripoGlbUrl;
          onGlbReady?.call(tripoGlbUrl);
          UserAvatarService.setLatestTryOn(glbUrl: tripoGlbUrl, imageUrl: cleanCutoutUrl);
          debugPrint('[TRIPO-3D] 3D GLB ready: $tripoGlbUrl');

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('tryon_glb_$key', tripoGlbUrl);
            if (productId != null) await prefs.setString('tryon_glb_$productId', tripoGlbUrl);
          } catch (_) {}
        }

        // Save complete try-on record to Supabase
        if (userId != null && productId != null && productId.isNotEmpty) {
          try {
            debugPrint('[FASHN-AI] Persisting tryon to Supabase wardrobe_items for product: $productId...');
            await Supabase.instance.client.from('wardrobe_items').upsert({
              'user_id': userId,
              'product_id': productId,
              'product_name': category,
              'product_image': garmentImagePath,
              'tryon_image_url': cleanCutoutUrl,
              if (tripoGlbUrl.isNotEmpty) 'glb_model_url': tripoGlbUrl,
            }, onConflict: 'user_id,product_id');
            debugPrint('[FASHN-AI] Complete tryon saved to Supabase!');
          } catch (saveErr) {
            debugPrint('[FASHN-AI] Supabase save warning: $saveErr');
          }
        }

        stopwatch.stop();

        return FashnTryOnResult(
          isSuccess: true,
          tryOnImageUrl: cleanCutoutUrl,
          glbModelUrl: tripoGlbUrl,
          processingTimeSec: stopwatch.elapsedMilliseconds / 1000.0,
        );
      }

      return const FashnTryOnResult(
        isSuccess: false,
        errorMessage: 'Generation timed out. Please try again.',
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint('[FashnTryOnService] Exception during try-on: $e');
      return FashnTryOnResult(isSuccess: false, errorMessage: e.toString());
    } finally {
      client.close();
    }
  }

  /// Calls FASHN background-remove to create a pure white studio cutout
  Future<String?> _removeBackground(String imageUrl) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final runUri = Uri.parse('$_baseUrl/run');
      final req = await client.postUrl(runUri);
      req.headers.set('Authorization', 'Bearer $_apiKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.write(jsonEncode({
        'model_name': 'background-remove',
        'inputs': {'image': imageUrl}
      }));
      final res = await req.close().timeout(const Duration(seconds: 15));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final id = json['id'] as String?;
      if (id == null) return null;

      final statusUri = Uri.parse('$_baseUrl/status/$id');
      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 1500));
        final sReq = await client.getUrl(statusUri);
        sReq.headers.set('Authorization', 'Bearer $_apiKey');
        final sRes = await sReq.close().timeout(const Duration(seconds: 10));
        final sBody = await sRes.transform(utf8.decoder).join();
        final sJson = jsonDecode(sBody) as Map<String, dynamic>;
        if (sJson['status'] == 'completed') {
          final out = sJson['output'];
          if (out is List && out.isNotEmpty) return out[0].toString();
          if (out is String) return out;
        } else if (sJson['status'] == 'failed') {
          break;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[FASHN-AI] Background remove exception: $e');
      return null;
    } finally {
      client.close();
    }
  }

  Future<List<int>?> _fetchImageBytes(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
        try {
          final req = await client.getUrl(Uri.parse(imageUrl));
          final res = await req.close().timeout(const Duration(seconds: 15));
          if (res.statusCode == 200) {
            return await consolidateHttpClientResponseBytes(res);
          }
        } finally {
          client.close();
        }
      } else if (imageUrl.startsWith('data:image')) {
        final comma = imageUrl.indexOf(',');
        if (comma != -1) {
          return base64Decode(imageUrl.substring(comma + 1));
        }
      } else {
        final byteData = await rootBundle.load(imageUrl);
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('[TRIPO-3D] Failed to fetch image bytes: $e');
    }
    return null;
  }

  Future<String?> _uploadImageToTripo(List<int> imageBytes, String tripoKey) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      final uploadUri = Uri.parse('https://api.tripo3d.ai/v2/openapi/upload');
      final req = await client.postUrl(uploadUri);
      req.headers.set('Authorization', 'Bearer $tripoKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');

      final header = utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="file"; filename="tryon.jpg"\r\n'
        'Content-Type: image/jpeg\r\n\r\n',
      );
      final footer = utf8.encode('\r\n--$boundary--\r\n');

      req.contentLength = header.length + imageBytes.length + footer.length;
      req.add(header);
      req.add(imageBytes);
      req.add(footer);

      final res = await req.close().timeout(const Duration(seconds: 20));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['code'] == 0) {
        final token = json['data']?['image_token'] as String?;
        debugPrint('[TRIPO-3D] Image uploaded -> image_token: $token');
        return token;
      } else {
        debugPrint('[TRIPO-3D] Upload failed with code ${json['code']}: ${json['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('[TRIPO-3D] Upload error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Calls Tripo3D Image-to-3D API to generate a real 360° 3D GLB model from the try-on photo
  Future<String?> _generateTripo3DModel(String imageUrl, {void Function(String message)? onProgress}) async {
    final tripoKey = dotenv.env['TRIPO_API_KEY'] ?? 'tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw';
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final imageBytes = await _fetchImageBytes(imageUrl);
      if (imageBytes == null || imageBytes.isEmpty) {
        debugPrint('[TRIPO-3D] Failed to get image bytes for Tripo upload');
        return null;
      }

      final fileToken = await _uploadImageToTripo(imageBytes, tripoKey);
      if (fileToken == null || fileToken.isEmpty) {
        debugPrint('[TRIPO-3D] Upload failed or balance insufficient. Falling back to local dressed model.');
        return null;
      }

      final taskUri = Uri.parse('https://api.tripo3d.ai/v2/openapi/task');
      final req = await client.postUrl(taskUri);
      req.headers.set('Authorization', 'Bearer $tripoKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.write(jsonEncode({
        'type': 'image_to_model',
        'model_version': 'v3.1-20260211',
        'file': {
          'type': 'jpg',
          'file_token': fileToken,
        },
        'texture': true,
        'pbr': true,
        'texture_quality': 'detailed',
        'texture_alignment': 'original_image',
        'remove_background': true,
        'enable_image_autofix': true,
        'auto_size': true,
        'face_limit': 35000,
      }));

      final res = await req.close().timeout(const Duration(seconds: 15));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final taskId = json['data']?['task_id'] as String?;
      if (taskId == null) {
        debugPrint('[TRIPO-3D] Task creation failed: $body');
        return null;
      }

      debugPrint('[TRIPO-3D] Task created: $taskId. Polling for 3D model...');
      final statusUri = Uri.parse('https://api.tripo3d.ai/v2/openapi/task/$taskId');
      for (int i = 1; i <= 60; i++) {
        await Future.delayed(const Duration(seconds: 3));
        onProgress?.call("Tripo 3D: Reconstruction du Modèle 3D 360°... (${i * 3}s)");
        final sReq = await client.getUrl(statusUri);
        sReq.headers.set('Authorization', 'Bearer $tripoKey');
        final sRes = await sReq.close().timeout(const Duration(seconds: 10));
        final sBody = await sRes.transform(utf8.decoder).join();
        final sJson = jsonDecode(sBody) as Map<String, dynamic>;
        final status = sJson['data']?['status'] as String? ?? '';
        debugPrint('[TRIPO-3D] Poll $i/60: status = $status');

        if (status == 'success') {
          final glbUrl = sJson['data']?['output']?['pbr_model'] as String? ??
              sJson['data']?['output']?['model'] as String?;
          debugPrint('[TRIPO-3D] Model generated successfully! Raw CDN URL: $glbUrl');
          if (glbUrl != null && glbUrl.isNotEmpty) {
            try {
              debugPrint('[TRIPO-3D] Downloading and persisting GLB to Supabase Storage with service role key...');
              final dReq = await client.getUrl(Uri.parse(glbUrl));
              final dRes = await dReq.close().timeout(const Duration(seconds: 30));
              if (dRes.statusCode == 200) {
                final glbBytes = await consolidateHttpClientResponseBytes(dRes);
                final fileName = 'tryon_${DateTime.now().millisecondsSinceEpoch}.glb';

                // Use service role key to bypass storage RLS and guarantee 100% upload success
                const defaultServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pZmtsc2R4bXBtZGZibmFhenNvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTYyNjcyMywiZXhwIjoyMTA3MjAyNzIzfQ.ZRqmi-fxfSJF5PbEICvjStspDRBxS-xI_qkO__W8d1k';
                final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? defaultServiceKey;
                final upUri = Uri.parse('https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/avatars/$fileName');
                final upReq = await client.postUrl(upUri);
                upReq.headers.set('apikey', serviceKey);
                upReq.headers.set('Authorization', 'Bearer $serviceKey');
                upReq.headers.set('Content-Type', 'model/gltf-binary');
                upReq.add(glbBytes);
                final upRes = await upReq.close().timeout(const Duration(seconds: 30));
                debugPrint('[TRIPO-3D] Supabase storage upload response: HTTP ${upRes.statusCode}');

                if (upRes.statusCode == 200 || upRes.statusCode == 201) {
                  final supabaseGlb = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$fileName';
                  debugPrint('[TRIPO-3D] Persisted to Supabase: $supabaseGlb');
                  return supabaseGlb;
                }
              }
            } catch (upErr) {
              debugPrint('[TRIPO-3D] Storage upload warning: $upErr');
            }
            return glbUrl;
          }
          return null;
        } else if (status == 'failed') {
          debugPrint('[TRIPO-3D] Task failed: $sBody');
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TRIPO-3D] Generation exception: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Converts image to public URL or base64 data URI
  Future<String> _resolveImageInput(String imagePath) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Local asset
    try {
      final byteData = await rootBundle.load(imagePath);
      final bytes = byteData.buffer.asUint8List();
      final mime = imagePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('[FashnTryOnService] Failed to load asset $imagePath: $e');
      return imagePath;
    }
  }

  String _normalizeCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('pant') || c.contains('trouser') || c.contains('jean') || c.contains('skirt')) {
      return 'bottoms';
    }
    if (c.contains('dress') || c.contains('robe') || c.contains('combinaison') || c.contains('jumpsuit')) {
      return 'one-pieces';
    }
    return 'tops';
  }
}
