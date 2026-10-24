import 'dart:convert';
import 'dart:math' as math;
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/system_notification_service.dart';
import '../../../core/localization/language_service.dart';

/// Model representing an In-App notification with bilingual support (EN/FR)
class NotificationItem {
  final String id;
  final String userId;
  final String titleEn;
  final String titleFr;
  final String bodyEn;
  final String bodyFr;
  final String category; // 'tryon', 'order', 'style', 'system'
  final String? imageUrl;
  final String? actionRoute;
  final Map<String, dynamic> actionPayload;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.titleEn,
    required this.titleFr,
    required this.bodyEn,
    required this.bodyFr,
    required this.category,
    this.imageUrl,
    this.actionRoute,
    this.actionPayload = const {},
    required this.isRead,
    required this.createdAt,
  });

  String getTitle(bool isEn) {
    if (isEn && titleEn.isNotEmpty) return titleEn;
    if (!isEn && titleFr.isNotEmpty) return titleFr;
    return titleEn.isNotEmpty ? titleEn : titleFr;
  }

  String getBody(bool isEn) {
    if (isEn && bodyEn.isNotEmpty) return bodyEn;
    if (!isEn && bodyFr.isNotEmpty) return bodyFr;
    return bodyEn.isNotEmpty ? bodyEn : bodyFr;
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? NotificationService.generateUuid(),
      userId: json['user_id']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? json['title']?.toString() ?? '',
      titleFr: json['title_fr']?.toString() ?? json['title']?.toString() ?? '',
      bodyEn: json['body_en']?.toString() ?? json['body']?.toString() ?? '',
      bodyFr: json['body_fr']?.toString() ?? json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'system',
      imageUrl: json['image_url']?.toString(),
      actionRoute: json['action_route']?.toString(),
      actionPayload: json['action_payload'] is Map<String, dynamic>
          ? json['action_payload'] as Map<String, dynamic>
          : {},
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title_en': titleEn,
      'title_fr': titleFr,
      'body_en': bodyEn,
      'body_fr': bodyFr,
      'category': category,
      'image_url': imageUrl,
      'action_route': actionRoute,
      'action_payload': actionPayload,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      userId: userId,
      titleEn: titleEn,
      titleFr: titleFr,
      bodyEn: bodyEn,
      bodyFr: bodyFr,
      category: category,
      imageUrl: imageUrl,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

/// Service to manage notifications, in-app notification center, real-time sync,
/// and external OS launcher app icon badging (EasyPaisa, Instagram style)
class NotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _localStoreKey = 'fitvisor_notifications_list_v4';

  /// Reactive unread count notifier listened by HomeScreen bell icon
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// RFC4122 v4 compliant UUID generator for Postgres UUID columns
  static String generateUuid() {
    final rnd = math.Random();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // v4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    return [
      bytes.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    ].join('-');
  }

  /// Safely update the external OS launcher app icon badge (home screen icon badge)
  static Future<void> _updateLauncherBadge(int count) async {
    try {
      final isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (_) {}
  }

  /// Load local notifications from SharedPreferences
  static Future<List<NotificationItem>> _loadLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_localStoreKey);
      if (rawList != null && rawList.isNotEmpty) {
        return rawList
            .map((item) => NotificationItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Save local notifications to SharedPreferences and backup to Supabase user_metadata
  static Future<void> _saveLocalNotifications(List<NotificationItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_localStoreKey, rawList);
    } catch (_) {}

    // Cloud backup to user_metadata for multi-device sync
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final serializedList = items.take(15).map((e) => e.toJson()).toList();
        await _supabase.auth.updateUser(
          UserAttributes(data: {
            'notifications_cache': serializedList,
            'notifications_updated_at': DateTime.now().toIso8601String(),
          }),
        );
      } catch (_) {}
    }
  }

  /// Fetch all notifications with fallback to local persistent storage
  static Future<List<NotificationItem>> fetchNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    List<NotificationItem> items = [];

    if (userId != null) {
      try {
        final response = await _supabase
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final List<dynamic> list = response as List<dynamic>;
        if (list.isNotEmpty) {
          items = list
              .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
              .toList();
          await _saveLocalNotifications(items);
        } else {
          items = await _loadLocalNotifications();
        }
      } catch (e) {
        debugPrint('[NotificationService] Supabase fetch notice: $e');
        items = await _loadLocalNotifications();
      }
    } else {
      items = await _loadLocalNotifications();
    }

    // If completely empty on startup, auto-generate the real Welcome notification
    if (items.isEmpty) {
      final welcome = _createWelcomeNotification();
      items = [welcome];
      await _saveLocalNotifications(items);
      await _syncToSupabaseTable(welcome);
    }

    final unread = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
    await _updateLauncherBadge(unread);
    return items;
  }

  /// Ensure Welcome / Welcome Back notification is present and marked unread.
  /// ALWAYS creates a distinct, separate container/card for new sessions without overwriting existing cards!
  static Future<NotificationItem> ensureWelcomeNotification() async {
    final items = await _loadLocalNotifications();
    final now = DateTime.now();

    // Avoid duplicate creation on rapid hot-reloads within 30 seconds
    final bool hasJustCreated = items.isNotEmpty &&
        now.difference(items.first.createdAt).inSeconds < 30;

    NotificationItem activeNotification;

    if (hasJustCreated) {
      activeNotification = items.first;
    } else {
      // Create a brand new distinct card/container
      activeNotification = items.isEmpty
          ? _createWelcomeNotification()
          : _createWelcomeBackNotification();

      // Insert at index 0 without overwriting any previous cards
      items.insert(0, activeNotification);

      await _saveLocalNotifications(items);
      await _syncToSupabaseTable(activeNotification);
    }

    final unread = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
    await _updateLauncherBadge(unread);

    // Trigger real Android system notification on phone status bar in active language (FR / EN)
    final isFr = LanguageService.instance.isFrench;
    SystemNotificationService.showNotification(
      title: isFr ? activeNotification.titleFr : activeNotification.titleEn,
      body: isFr ? activeNotification.bodyFr : activeNotification.bodyEn,
    );

    return activeNotification;
  }

  /// Add incoming FCM or system notification to the notification center as a new distinct card
  static Future<void> addIncomingNotification({
    required String title,
    required String body,
    String? titleFr,
    String? bodyFr,
    String category = 'system',
    String? actionRoute,
  }) async {
    final isFr = LanguageService.instance.isFrench;
    final resolvedTitleFr = titleFr ?? (isFr ? title : _frenchFallbackTitle(title));
    final resolvedBodyFr = bodyFr ?? (isFr ? body : _frenchFallbackBody(body));
    final resolvedTitleEn = isFr ? (titleFr ?? title) : title;
    final resolvedBodyEn = isFr ? (bodyFr ?? body) : body;

    final newItem = NotificationItem(
      id: generateUuid(),
      userId: _supabase.auth.currentUser?.id ?? '5b51eb01-ec17-4ed8-a7e5-4514c13c0297',
      titleEn: resolvedTitleEn,
      titleFr: resolvedTitleFr,
      bodyEn: resolvedBodyEn,
      bodyFr: resolvedBodyFr,
      category: category,
      imageUrl: 'assets/images/logo.png',
      actionRoute: actionRoute,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final items = await _loadLocalNotifications();
    items.insert(0, newItem);
    await _saveLocalNotifications(items);
    await _syncToSupabaseTable(newItem);

    final unread = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
    await _updateLauncherBadge(unread);

    // Trigger real Android system notification on phone status bar with active language
    SystemNotificationService.showNotification(
      title: isFr ? resolvedTitleFr : resolvedTitleEn,
      body: isFr ? resolvedBodyFr : resolvedBodyEn,
    );
  }

  static String _frenchFallbackTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('welcome back')) return 'Bon retour sur FitVisor ! ✨';
    if (lower.contains('welcome')) return 'Bienvenue sur FitVisor ! 🎉';
    if (lower.contains('try') || lower.contains('drape')) return 'Essayage 3D Prêt ✨';
    if (lower.contains('order')) return 'Mise à jour de commande 📦';
    if (lower.contains('profile')) return 'Profil mis à jour ✅';
    return title;
  }

  static String _frenchFallbackBody(String body) {
    final lower = body.toLowerCase();
    if (lower.contains('virtual') || lower.contains('styling studio') || lower.contains('calibrated')) {
      return 'Votre studio de style 3D virtuel est prêt. Découvrez vos tenues personnalisées.';
    }
    if (lower.contains('try-on') || lower.contains('avatar')) {
      return 'Votre rendu 3D personnalisé est disponible dans votre dressing.';
    }
    return body;
  }

  /// Helper to safely sync a notification into Supabase notifications table
  static Future<void> _syncToSupabaseTable(NotificationItem item) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final payload = {
        'id': item.id,
        'user_id': userId,
        'title_en': item.titleEn,
        'title_fr': item.titleFr,
        'body_en': item.bodyEn,
        'body_fr': item.bodyFr,
        'category': item.category,
        'image_url': item.imageUrl,
        'action_route': item.actionRoute,
        'action_payload': item.actionPayload,
        'is_read': item.isRead,
        'created_at': item.createdAt.toIso8601String(),
      };
      await _supabase.from('notifications').upsert(payload);
      debugPrint('[NotificationService] Synced notification ${item.id} to Supabase table.');
    } catch (e) {
      debugPrint('[NotificationService] Supabase table sync notice: $e');
    }
  }

  /// Mark specific notification as read
  static Future<bool> markAsRead(String notificationId) async {
    final items = await _loadLocalNotifications();
    final idx = items.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(isRead: true);
      await _saveLocalNotifications(items);
    }

    final unread = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
    await _updateLauncherBadge(unread);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase
            .from('notifications')
            .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
            .eq('id', notificationId);
      } catch (_) {}
    }
    return true;
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    final items = await _loadLocalNotifications();
    final updated = items.map((n) => n.copyWith(isRead: true)).toList();
    await _saveLocalNotifications(updated);

    unreadCountNotifier.value = 0;
    await _updateLauncherBadge(0);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase
            .from('notifications')
            .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
            .eq('user_id', userId)
            .eq('is_read', false);
      } catch (_) {}
    }
    return true;
  }

  /// Delete a single notification
  static Future<bool> deleteNotification(String notificationId) async {
    final items = await _loadLocalNotifications();
    items.removeWhere((n) => n.id == notificationId);
    await _saveLocalNotifications(items);

    final unread = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
    await _updateLauncherBadge(unread);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase.from('notifications').delete().eq('id', notificationId);
      } catch (_) {}
    }
    return true;
  }

  /// Clear all notifications completely
  static Future<bool> clearAllNotifications() async {
    await _saveLocalNotifications([]);
    unreadCountNotifier.value = 0;
    await _updateLauncherBadge(0);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase.from('notifications').delete().eq('user_id', userId);
      } catch (_) {}
    }
    return true;
  }

  /// Count unread notifications accurately
  static Future<int> getUnreadCount() async {
    final items = await _loadLocalNotifications();
    final count = items.where((n) => !n.isRead).length;
    unreadCountNotifier.value = count;
    await _updateLauncherBadge(count);
    return count;
  }

  /// Creates initial Welcome notification
  static NotificationItem _createWelcomeNotification() {
    return NotificationItem(
      id: generateUuid(),
      userId: _supabase.auth.currentUser?.id ?? '5b51eb01-ec17-4ed8-a7e5-4514c13c0297',
      titleEn: 'Welcome to FitVisor!',
      titleFr: 'Bienvenue sur FitVisor !',
      bodyEn: 'Your styling studio is calibrated. Explore your virtual 3D wardrobe and start trying on styles tailored to your morphology.',
      bodyFr: 'Votre studio de style est calibré. Explorez votre dressing virtuel 3D et commencez vos essayages personnalisés.',
      category: 'system',
      imageUrl: 'assets/images/logo.png',
      actionRoute: '/home',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Creates fresh Welcome Back notification on session re-entry
  static NotificationItem _createWelcomeBackNotification() {
    return NotificationItem(
      id: generateUuid(),
      userId: _supabase.auth.currentUser?.id ?? '5b51eb01-ec17-4ed8-a7e5-4514c13c0297',
      titleEn: 'Welcome back to FitVisor!',
      titleFr: 'Bon retour sur FitVisor !',
      bodyEn: 'Your 3D virtual styling studio is ready. Explore new curated styles and 3D outfit combinations tailored to your morphology.',
      bodyFr: 'Votre studio de style 3D virtuel est prêt. Découvrez nos nouvelles tenues adaptées à votre morphologie.',
      category: 'system',
      imageUrl: 'assets/images/logo.png',
      actionRoute: '/home',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }
}

