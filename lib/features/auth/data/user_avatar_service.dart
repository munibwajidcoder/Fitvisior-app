import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to persist and synchronize user profile picture across all screens
class UserAvatarService {
  static final ValueNotifier<File?> avatarNotifier = ValueNotifier<File?>(null);

  /// Load user avatar from disk/preferences on startup
  static Future<void> loadSavedAvatar() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? 'user_avatar_path_$userId' : 'user_avatar_path_default';
      final savedPath = prefs.getString(key);
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          avatarNotifier.value = file;
          return;
        }
      }

      // Check standard document path
      final dir = await getApplicationDocumentsDirectory();
      final prefix = 'user_avatar_${userId ?? "default"}';
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

  /// Save picked image file permanently to app documents
  static Future<File?> saveAvatar(File sourceFile) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/user_avatar_${userId ?? "default"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = await sourceFile.copy(targetPath);

      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? 'user_avatar_path_$userId' : 'user_avatar_path_default';
      await prefs.setString(key, targetFile.path);

      avatarNotifier.value = targetFile;
      return targetFile;
    } catch (e) {
      debugPrint('[UserAvatarService] Error saving avatar: $e');
      return null;
    }
  }
}
