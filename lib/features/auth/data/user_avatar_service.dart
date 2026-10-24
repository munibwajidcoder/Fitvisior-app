import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Service to persist and synchronize user profile picture and 3D avatar GLB across all screens
/// with rock-solid cloud restoration across app reinstallation.
class UserAvatarService {
  static final ValueNotifier<File?> avatarNotifier = ValueNotifier<File?>(null);
  static final ValueNotifier<String?> avatarGlbNotifier = ValueNotifier<String?>(null);

  /// Clear all avatar data on logout — MUST be called to prevent cross-account privacy leaks
  static void clearAvatar() {
    avatarNotifier.value = null;
    avatarGlbNotifier.value = null;
  }

  /// Load user avatar and 3D GLB model from disk/cloud on startup or after reinstall.
  static Future<void> loadSavedAvatar() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;
      if (userId == null) {
        debugPrint('[UserAvatarService] No logged-in user. Avatar not loaded.');
        return;
      }
      final prefs = await SharedPreferences.getInstance();

      // ── 1. Load THIS user's 3D GLB model path ───────────────────────────
      final savedGlb = prefs.getString('user_avatar_glb_$userId');
      if (savedGlb != null && savedGlb.isNotEmpty) {
        avatarGlbNotifier.value = savedGlb;
      }
      if (avatarGlbNotifier.value == null || avatarGlbNotifier.value!.isEmpty) {
        try {
          final profile = await AuthService.getProfile();
          String? profileGlb = profile?['avatar_glb_url'] as String?;
          profileGlb ??= user?.userMetadata?['avatar_glb_url'] as String?;
          if (profileGlb != null && profileGlb.isNotEmpty) {
            avatarGlbNotifier.value = profileGlb;
            await prefs.setString('user_avatar_glb_$userId', profileGlb);
          } else {
            final g = (profile?['gender'] as String?)?.toLowerCase() ?? '';
            final isMale = g.contains('homme') || g.contains('male');
            avatarGlbNotifier.value = isMale
                ? 'assets/models/base_avatar_male.glb'
                : 'assets/models/base_avatar_female.glb';
          }
        } catch (_) {}
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
      final metaBase64 = user?.userMetadata?['avatar_base64'] as String?;
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

      // ── 4. Try downloading from Supabase storage public URL ─────────────
      final avatarUrl = (user?.userMetadata?['avatar_url'] as String?) ??
          'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$userId.jpg';

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

      // ── 5. Device backup fallback ───────────────────────────────────────
      final deviceBackup = File('${dir.path}/latest_device_avatar.jpg');
      if (await deviceBackup.exists()) {
        avatarNotifier.value = deviceBackup;
        return;
      }
    } catch (e) {
      debugPrint('[UserAvatarService] Error loading avatar: $e');
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

      // Save a local device backup
      final deviceBackupPath = '${dir.path}/latest_device_avatar.jpg';
      try {
        await sourceFile.copy(deviceBackupPath);
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path_$userId', targetFile.path);
      avatarNotifier.value = targetFile;

      final bytes = await sourceFile.readAsBytes();

      // Safe cloud upload to Supabase storage 'avatars' bucket
      String? publicUrl;
      try {
        await Supabase.instance.client.storage.from('avatars').uploadBinary(
              '$userId.jpg',
              bytes,
              fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
            );
        publicUrl = 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/$userId.jpg';
        debugPrint('[UserAvatarService] Uploaded avatar to Supabase storage bucket.');
      } catch (uploadErr) {
        debugPrint('[UserAvatarService] Cloud storage upload warning: $uploadErr');
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

    final isMale = (gender ?? '').toLowerCase().contains('homme') ||
        (gender ?? '').toLowerCase().contains('male');
    return isMale
        ? 'assets/models/base_avatar_male.glb'
        : 'assets/models/base_avatar_female.glb';
  }

  /// Save 3D Avatar GLB path/URL permanently
  static Future<void> saveAvatarGlbUrl(String glbUrl) async {
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
}
