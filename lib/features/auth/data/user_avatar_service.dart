import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service to persist and synchronize user profile picture and 3D avatar GLB across all screens
/// with rock-solid cloud restoration across app reinstallation.
class UserAvatarService {
  static final ValueNotifier<File?> avatarNotifier = ValueNotifier<File?>(null);
  static final ValueNotifier<String?> avatarGlbNotifier = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> latestTryOnGlbNotifier = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> latestTryOnImageNotifier = ValueNotifier<String?>(null);
  static final ValueNotifier<int> tryOnsCountNotifier = ValueNotifier<int>(0);

  /// Sets the latest virtual try-on result so all screens (AR Mirror, Change Size, etc.)
  /// immediately show the dressed avatar rather than the bare body scan.
  static void setLatestTryOn({String? glbUrl, String? imageUrl}) {
    if (glbUrl != null && glbUrl.isNotEmpty) {
      latestTryOnGlbNotifier.value = glbUrl;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      latestTryOnImageNotifier.value = imageUrl;
    }
    incrementTryOnCount();
  }

  /// Clear all avatar data on logout — MUST be called to prevent cross-account privacy leaks
  static void clearAvatar() {
    avatarNotifier.value = null;
    avatarGlbNotifier.value = null;
    latestTryOnGlbNotifier.value = null;
    latestTryOnImageNotifier.value = null;
    tryOnsCountNotifier.value = 0;
  }

  /// Load user avatar and 3D GLB model from disk/cloud on startup or after reinstall.
  static Future<void> loadSavedAvatar() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('[UserAvatarService] No logged-in user. Avatar not loaded.');
        avatarNotifier.value = null;
        avatarGlbNotifier.value = null;
        return;
      }
      final userId = user.id;
      final prefs = await SharedPreferences.getInstance();

      // Clean up any legacy shared avatar files from older app versions
      try {
        final dir = await getApplicationDocumentsDirectory();
        final legacyFiles = [
          File('${dir.path}/latest_device_avatar.jpg'),
          File('${dir.path}/user_avatar_default.jpg'),
          File('${dir.path}/user_avatar_guest_user.jpg'),
        ];
        for (final lf in legacyFiles) {
          if (await lf.exists()) {
            await lf.delete();
            debugPrint('[UserAvatarService] Purged legacy device avatar: ${lf.path}');
          }
        }
      } catch (_) {}

      // ── 1. Load THIS user's 3D GLB model path ───────────────────────────
      final savedGlb = prefs.getString('user_avatar_glb_$userId');
      final metaGlb = user.userMetadata?['avatar_glb_url'] as String?;

      if (metaGlb != null && metaGlb.isNotEmpty) {
        avatarGlbNotifier.value = metaGlb;
        await prefs.setString('user_avatar_glb_$userId', metaGlb);
        debugPrint('[UserAvatarService] Loaded avatar for $userId: $metaGlb');
      } else if (savedGlb != null && savedGlb.isNotEmpty) {
        avatarGlbNotifier.value = savedGlb;
      } else {
        try {
          final profile = await AuthService.getProfile();
          String? profileGlb = profile?['avatar_glb_url'] as String?;
          profileGlb ??= metaGlb;
          if (profileGlb != null && profileGlb.isNotEmpty && !profileGlb.contains('base_avatar')) {
            avatarGlbNotifier.value = profileGlb;
            await prefs.setString('user_avatar_glb_$userId', profileGlb);
          } else {
            avatarGlbNotifier.value = null;
          }
        } catch (_) {
          avatarGlbNotifier.value = null;
        }
      }

      // Auto-migrate legacy Tripo OpenAPI URL to Supabase Storage if needed
      final activeGlb = avatarGlbNotifier.value;
      if (activeGlb != null && (activeGlb.contains('openapi.tripo3d.ai') || activeGlb.contains('api.tripo3d.ai'))) {
        debugPrint('[UserAvatarService] Background converting Tripo GLB URL to Supabase storage...');
        persistGlbToStorage(activeGlb);
      }

      // ── 2. Load THIS user's 2D profile image ────────────────────────────
      final dir = await getApplicationDocumentsDirectory();
      final standardFile = File('${dir.path}/user_avatar_$userId.jpg');

      // Check local cache first
      final savedPath = prefs.getString('user_avatar_path_$userId');
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          avatarNotifier.value = file;
          return;
        }
      }

      if (await standardFile.exists()) {
        avatarNotifier.value = standardFile;
        await prefs.setString('user_avatar_path_$userId', standardFile.path);
        return;
      }

      // ── 3. CLOUD RESTORE ON FRESH REINSTALLATION ────────────────────────
      // Check Supabase Auth user_metadata (already in memory from login)
      final metaBase64 = user.userMetadata?['avatar_base64'] as String?;
      if (metaBase64 != null && metaBase64.isNotEmpty) {
        try {
          final decodedBytes = base64Decode(metaBase64);
          await standardFile.writeAsBytes(decodedBytes);
          avatarNotifier.value = standardFile;
          await prefs.setString('user_avatar_path_$userId', standardFile.path);
          debugPrint('[UserAvatarService] RESTORED avatar from userMetadata base64 on fresh reinstall!');
          return;
        } catch (e) {
          debugPrint('[UserAvatarService] Error restoring from base64 metadata: $e');
        }
      }

      // ── 4. Try downloading from Supabase storage (metadata, profile table, or avatars bucket)
      String? avatarUrl = user.userMetadata?['avatar_url'] as String?;
      if (avatarUrl == null || avatarUrl.isEmpty) {
        try {
          final profile = await AuthService.getProfile();
          avatarUrl = profile?['avatar_url'] as String?;
        } catch (_) {}
      }
      avatarUrl ??= 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$userId.jpg';

      if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
        try {
          final uri = Uri.parse(avatarUrl);
          final request = await HttpClient().getUrl(uri);
          final response = await request.close();
          if (response.statusCode == 200) {
            final bytes = await consolidateHttpClientResponseBytes(response);
            if (bytes.isNotEmpty) {
              await standardFile.writeAsBytes(bytes);
              avatarNotifier.value = standardFile;
              await prefs.setString('user_avatar_path_$userId', standardFile.path);
              debugPrint('[UserAvatarService] RESTORED avatar from Supabase storage URL on fresh reinstall!');
              return;
            }
          }
        } catch (downErr) {
          debugPrint('[UserAvatarService] Storage download error: $downErr');
        }
      }

      // ── 5. User-isolated: if user has no avatar, keep null (do not leak other users' photos)
      avatarNotifier.value = null;
    } catch (e) {
      debugPrint('[UserAvatarService] Error loading avatar: $e');
      avatarNotifier.value = null;
    }
  }

  /// Helper to upload bytes directly to Supabase Storage avatars bucket
  static Future<bool> _uploadToStorageDirect(String fileName, List<int> bytes, String contentType) async {
    // 1. Try native Supabase Storage SDK first
    try {
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );
      debugPrint('[UserAvatarService] Storage upload successful via Supabase SDK: $fileName');
      return true;
    } catch (sdkErr) {
      debugPrint('[UserAvatarService] Supabase SDK storage upload note: $sdkErr, trying direct HTTP fallback...');
    }

    // 2. Direct HTTP fallback with service role key
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 25);
    try {
      final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      final uri = Uri.parse('https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/avatars/$fileName');
      final req = await client.postUrl(uri);
      req.headers.set('apikey', serviceKey);
      req.headers.set('Authorization', 'Bearer $serviceKey');
      req.headers.set('Content-Type', contentType);
      req.headers.set('x-upsert', 'true');
      req.add(bytes);
      final res = await req.close().timeout(const Duration(seconds: 25));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }
      debugPrint('[UserAvatarService] Storage direct upload status: ${res.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[UserAvatarService] Storage direct upload error: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// Save picked/captured image permanently — persists to disk, storage, and user_metadata
  static Future<File?> saveAvatar(File sourceFile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'guest_user';
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/user_avatar_$userId.jpg';
      final targetFile = await sourceFile.copy(targetPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path_$userId', targetFile.path);
      avatarNotifier.value = targetFile;

      final bytes = await sourceFile.readAsBytes();

      // Safe cloud upload to Supabase storage 'avatars' bucket
      String? publicUrl;
      final fileName = '$userId.jpg';
      final uploaded = await _uploadToStorageDirect(fileName, bytes, 'image/jpeg');
      if (uploaded) {
        publicUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$fileName';
        debugPrint('[UserAvatarService] Uploaded avatar to Supabase storage bucket: $publicUrl');
      }

      // Update Supabase Auth user_metadata with URL only (never base64 to avoid Cloudflare 400 header limit)
      if (user != null) {
        try {
          final Map<String, dynamic> metadata = {
            'avatar_updated_at': DateTime.now().toIso8601String(),
            'avatar_base64': null, // Ensure clean metadata
          };
          if (publicUrl != null) metadata['avatar_url'] = publicUrl;

          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: metadata),
          );
          debugPrint('[UserAvatarService] Saved avatar URL into Supabase user_metadata successfully!');
        } catch (metaErr) {
          debugPrint('[UserAvatarService] user_metadata update warning: $metaErr');
        }

        try {
          if (publicUrl != null) {
            await AuthService.updateProfile({'avatar_url': publicUrl});
          }
        } catch (_) {}
      }

      return targetFile;
    } catch (e) {
      debugPrint('[UserAvatarService] Error saving avatar: $e');
      return null;
    }
  }

  /// Uploads user's 3 scan photos (Front, Side, Back) to Supabase Storage avatars bucket
  /// and updates profiles table with scan_front_photo_url, scan_side_photo_url, scan_back_photo_url, and avatar_url
  static Future<Map<String, String?>> uploadScanPhotos(List<String?>? imagePaths) async {
    final Map<String, String?> urls = {
      'scan_front_photo_url': null,
      'scan_side_photo_url': null,
      'scan_back_photo_url': null,
    };
    if (imagePaths == null || imagePaths.isEmpty) return urls;

    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;
    if (userId == null) return urls;

    final poses = ['front', 'side', 'back'];
    final columnKeys = [
      'scan_front_photo_url',
      'scan_side_photo_url',
      'scan_back_photo_url',
    ];

    final Map<String, dynamic> updatePayload = {};

    for (int i = 0; i < imagePaths.length && i < 3; i++) {
      final path = imagePaths[i];
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!await file.exists()) continue;

      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) continue;

        final fileName = 'scan_${poses[i]}_$userId.jpg';
        final uploaded = await _uploadToStorageDirect(fileName, bytes, 'image/jpeg');

        if (uploaded) {
          final publicUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$fileName';
          urls[columnKeys[i]] = publicUrl;
          updatePayload[columnKeys[i]] = publicUrl;

          // If front photo, also set avatar_url and save locally
          if (i == 0) {
            updatePayload['avatar_url'] = publicUrl;
            avatarNotifier.value = file;
          }
        }
      } catch (e) {
        debugPrint('[UserAvatarService] Error uploading ${poses[i]} photo: $e');
      }
    }

    if (updatePayload.isNotEmpty) {
      try {
        await AuthService.updateProfile(updatePayload);
        // Direct Supabase table upsert to guarantee column persistence
        await Supabase.instance.client
            .from('profiles')
            .upsert({
              'id': userId,
              ...updatePayload,
            });
        debugPrint('[UserAvatarService] Successfully saved scan photos to profile: $updatePayload');
      } catch (e) {
        debugPrint('[UserAvatarService] Error updating profile with scan URLs: $e');
      }
    }

    return urls;
  }

  /// Delete current user's profile photo from disk, preferences, and cloud
  static Future<void> deleteProfilePhoto() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;
      avatarNotifier.value = null;

      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_avatar_path_$userId');

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/user_avatar_$userId.jpg');
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }

        // Clear in cloud
        try {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: {
              'avatar_url': null,
              'avatar_base64': null,
            }),
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[UserAvatarService] Error deleting profile photo: $e');
    }
  }

  /// Get current 3D Avatar GLB source
  static Future<String?> getAvatarGlbUrl({String? gender}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    if (avatarGlbNotifier.value != null && avatarGlbNotifier.value!.isNotEmpty) {
      return avatarGlbNotifier.value!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGlb = prefs.getString('user_avatar_glb_$userId');
      if (savedGlb != null && savedGlb.isNotEmpty) {
        avatarGlbNotifier.value = savedGlb;
        return savedGlb;
      }
    } catch (_) {}

    try {
      final profile = await AuthService.getProfile();
      final profileGlb = profile?['avatar_glb_url'] as String?;
      if (profileGlb != null && profileGlb.isNotEmpty) {
        avatarGlbNotifier.value = profileGlb;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_avatar_glb_$userId', profileGlb);
        } catch (_) {}
        return profileGlb;
      }
    } catch (_) {}

    // If no custom avatar has been generated yet, return null
    return null;
  }

  /// Persists GLB model to local device storage AND Supabase Storage avatars bucket
  static Future<String?> persistGlbToStorage(String rawGlbUrl) async {
    if (rawGlbUrl.isEmpty || rawGlbUrl.contains('base_avatar')) return null;

    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // If it's already a Supabase storage URL, just save and return
    if (rawGlbUrl.contains('supabase.co/storage/v1/object/public/avatars/')) {
      await saveAvatarGlbUrl(rawGlbUrl);
      return rawGlbUrl;
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 35);
    try {
      final uri = Uri.parse(rawGlbUrl);
      final req = await client.getUrl(uri);
      final tripoKey = dotenv.env['TRIPO_API_KEY'] ?? 'tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw';
      if (rawGlbUrl.contains('tripo3d.ai')) {
        req.headers.set('Authorization', 'Bearer $tripoKey');
      }
      final res = await req.close().timeout(const Duration(seconds: 45));
      if (res.statusCode == 200) {
        final glbBytes = await consolidateHttpClientResponseBytes(res);
        if (glbBytes.isNotEmpty) {
          // 1. Save locally to disk for instant, offline, zero-CORS loading
          final dir = await getApplicationDocumentsDirectory();
          final localFile = File('${dir.path}/user_avatar_model_$userId.glb');
          await localFile.writeAsBytes(glbBytes);
          debugPrint('[UserAvatarService] Saved local GLB: ${localFile.path} (${glbBytes.length} bytes)');

          // 2. Upload to Supabase Storage avatars bucket
          final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';
          final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.glb';
          final upUri = Uri.parse('https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/avatars/$fileName');
          final upReq = await client.postUrl(upUri);
          upReq.headers.set('apikey', serviceKey);
          upReq.headers.set('Authorization', 'Bearer $serviceKey');
          upReq.headers.set('Content-Type', 'model/gltf-binary');
          upReq.add(glbBytes);
          final upRes = await upReq.close().timeout(const Duration(seconds: 35));

          if (upRes.statusCode == 200 || upRes.statusCode == 201) {
            final publicSupabaseUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$fileName';
            debugPrint('[UserAvatarService] Uploaded GLB to Supabase Storage: $publicSupabaseUrl');

            await saveAvatarGlbUrl(publicSupabaseUrl);
            return publicSupabaseUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('[UserAvatarService] Persist GLB warning: $e');
    } finally {
      client.close();
    }
    return null;
  }

  /// Save 3D Avatar GLB path/URL permanently
  static Future<void> saveAvatarGlbUrl(String glbUrl) async {
    if (glbUrl.isEmpty || glbUrl.contains('base_avatar')) return;
    avatarGlbNotifier.value = glbUrl;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_glb_$userId', glbUrl);

      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_glb_url': glbUrl}),
        );
        await AuthService.updateProfile({'avatar_glb_url': glbUrl});
      } catch (_) {}
    } catch (e) {
      debugPrint('[UserAvatarService] Error saving GLB url: $e');
    }
  }

  /// Increment virtual try-on counter (called whenever 3D try-on or Fashn try-on executes)
  static Future<int> incrementTryOnCount() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final key = 'virtual_tryons_count_$userId';
    final current = (prefs.getInt(key) ?? tryOnsCountNotifier.value) + 1;
    await prefs.setInt(key, current);
    tryOnsCountNotifier.value = current;

    // Persist to Supabase profiles table
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'virtual_tryons_count': current,
        }).eq('id', user.id);
        debugPrint('[UserAvatarService] Synced virtual_tryons_count ($current) to Supabase');
      } catch (e) {
        debugPrint('[UserAvatarService] Could not update virtual_tryons_count on profiles: $e');
      }
    }
    return current;
  }

  /// Get current try-on count from cloud or local prefs
  static Future<int> getTryOnCount() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final key = 'virtual_tryons_count_$userId';
    int count = prefs.getInt(key) ?? 0;

    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('profiles')
            .select('virtual_tryons_count')
            .eq('id', user.id)
            .maybeSingle();
        if (res != null && res['virtual_tryons_count'] != null) {
          final dbCount = int.tryParse(res['virtual_tryons_count'].toString()) ?? count;
          if (dbCount > count) count = dbCount;
          await prefs.setInt(key, count);
        }
      } catch (_) {}
    }
    tryOnsCountNotifier.value = count;
    return count;
  }
}
