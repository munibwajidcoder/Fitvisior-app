import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Service to persist and synchronize user profile picture and 3D avatar GLB across all screens
class UserAvatarService {
  static final ValueNotifier<File?> avatarNotifier = ValueNotifier<File?>(null);
  // Starts as null — only set after loading the CURRENT user's own GLB
  static final ValueNotifier<String?> avatarGlbNotifier = ValueNotifier<String?>(null);

  /// Clear all avatar data on logout — MUST be called to prevent cross-account privacy leaks
  static void clearAvatar() {
    avatarNotifier.value = null;
    avatarGlbNotifier.value = null;
  }

  /// Load user avatar and 3D GLB model from disk/preferences on startup.
  /// STRICTLY uses the logged-in user's ID to prevent cross-account privacy leaks.
  static Future<void> loadSavedAvatar() async {
    // Always clear first to ensure no stale data from a previous session
    clearAvatar();
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('[UserAvatarService] No logged-in user. Avatar not loaded.');
        return;
      }
      final prefs = await SharedPreferences.getInstance();

      // 1. Load THIS user's 3D GLB model path ONLY (no fallback to other users or shared key)
      final savedGlb = prefs.getString('user_avatar_glb_$userId');
      if (savedGlb != null && savedGlb.isNotEmpty) {
        avatarGlbNotifier.value = savedGlb;
      }
      // If no saved GLB in local prefs, attempt to fetch from Supabase profile or fallback to gender model
      if (avatarGlbNotifier.value == null || avatarGlbNotifier.value!.isEmpty) {
        try {
          final profile = await AuthService.getProfile();
          final profileGlb = profile?['avatar_glb_url'] as String?;
          if (profileGlb != null && profileGlb.isNotEmpty) {
            avatarGlbNotifier.value = profileGlb;
          } else {
            final g = (profile?['gender'] as String?)?.toLowerCase() ?? '';
            final isMale = g.contains('homme') || g.contains('male');
            avatarGlbNotifier.value = isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb';
          }
        } catch (_) {}
      }

      // 2. Load THIS user's 2D profile image ONLY
      final savedPath = prefs.getString('user_avatar_path_$userId');
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          avatarNotifier.value = file;
          return;
        }
      }

      // Check standard document path for THIS user only
      final dir = await getApplicationDocumentsDirectory();
      final prefix = 'user_avatar_$userId';
      final entries = dir.listSync();
      for (final entity in entries) {
        if (entity is File && entity.path.contains(prefix)) {
          avatarNotifier.value = entity;
          return;
        }
      }
    } catch (e) {
      debugPrint('[UserAvatarService] Error loading avatar: $e');
    }
  }

  /// Save picked image file permanently to app documents — tied to current user ID only
  static Future<File?> saveAvatar(File sourceFile) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null; // Never save without a user ID
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/user_avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = await sourceFile.copy(targetPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path_$userId', targetFile.path);

      avatarNotifier.value = targetFile;
      return targetFile;
    } catch (e) {
      debugPrint('[UserAvatarService] Error saving avatar: $e');
      return null;
    }
  }

  /// Get current 3D Avatar GLB source — strictly for current logged-in user only.
  /// Returns null if user has no avatar (do not fall back to other user's data).
  static Future<String?> getAvatarGlbUrl({String? gender}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    // 1. Return from in-memory notifier if already loaded
    if (avatarGlbNotifier.value != null && avatarGlbNotifier.value!.isNotEmpty) {
      return avatarGlbNotifier.value!;
    }

    // 2. Try from local SharedPreferences (user-scoped key)
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGlb = prefs.getString('user_avatar_glb_$userId');
      if (savedGlb != null && savedGlb.isNotEmpty) {
        avatarGlbNotifier.value = savedGlb;
        return savedGlb;
      }
    } catch (_) {}

    // 3. Try from Supabase profile (fallback for new device logins)
    try {
      final profile = await AuthService.getProfile();
      final profileGlb = profile?['avatar_glb_url'] as String?;
      if (profileGlb != null && profileGlb.isNotEmpty) {
        avatarGlbNotifier.value = profileGlb;
        // Also persist locally for offline use
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_avatar_glb_$userId', profileGlb);
        } catch (_) {}
        return profileGlb;
      }
    } catch (_) {}

    // Fallback to base avatar model according to gender
    final isMale = (gender ?? '').toLowerCase().contains('homme') || (gender ?? '').toLowerCase().contains('male');
    return isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb';
  }

  /// Save 3D Avatar GLB path/URL permanently — strictly tied to current user ID
  static Future<void> saveAvatarGlbUrl(String glbUrl) async {
    avatarGlbNotifier.value = glbUrl;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return; // Never save without a user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_glb_$userId', glbUrl);
    } catch (e) {
      debugPrint('[UserAvatarService] Error saving GLB url: $e');
    }
  }
}
