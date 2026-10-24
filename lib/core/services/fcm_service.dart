import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/home/data/notification_service.dart';

/// Top-level background handler for FCM messages when app is closed / background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message ID: ${message.messageId}');
  debugPrint('[FCM Background] Title: ${message.notification?.title}');
  debugPrint('[FCM Background] Body: ${message.notification?.body}');
}

/// Production-ready Firebase Cloud Messaging (FCM) Service
/// Handles Push Notifications, Device Tokens, Badges, and Foreground Alerts
class FcmService {
  static final ValueNotifier<String?> fcmTokenNotifier = ValueNotifier<String?>(null);

  /// Callback when a foreground notification is received (listened by HomeScreen)
  static final ValueNotifier<RemoteMessage?> foregroundMessageNotifier = ValueNotifier<RemoteMessage?>(null);

  /// Initialize Firebase & FCM
  static Future<void> initialize() async {
    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        await Firebase.initializeApp();
        debugPrint('[FCM] Firebase initialized successfully.');

        // Set background handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Request permissions for Notifications & Badges
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          announcement: false,
          carPlay: false,
          criticalAlert: false,
        );

        debugPrint('============================================================');
        debugPrint('🔥 [FIREBASE / FCM DIAGNOSTIC REPORT]');
        debugPrint('============================================================');
        debugPrint('Firebase Core Status: INITIALIZED ✅');
        debugPrint('Permission Status: ${settings.authorizationStatus}');

        // Fetch Device FCM Token
        final token = await fetchAndSyncFcmToken();
        debugPrint('Active FCM Device Token:');
        debugPrint('>>> $token <<<');
        debugPrint('============================================================');

        // Listen for token updates
        // ignore: deprecated_member_use
        messaging.onTokenRefresh.listen((newToken) async {
          debugPrint('[FCM] Token refreshed: $newToken');
          await _saveAndSyncToken(newToken);
        });

        // Listen for Foreground Messages (App Open)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[FCM Foreground] Got message: ${message.notification?.title}');
          foregroundMessageNotifier.value = message;

          // Increment unread count badge
          NotificationService.getUnreadCount();
        });

        // Handle when notification opened from background state
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('[FCM Open] Notification clicked from background: ${message.data}');
          NotificationService.getUnreadCount();
        });

        // Check if app was launched directly by tapping a notification
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('[FCM Launch] App launched via notification: ${initialMessage.data}');
          NotificationService.getUnreadCount();
        }
      }
    } catch (e) {
      debugPrint('============================================================');
      debugPrint('❌ [FIREBASE / FCM INITIALIZATION NOTICE]');
      debugPrint('============================================================');
      debugPrint('Notice: $e');
      debugPrint('Reason: Native plugins require rebuilding the APK once.');
      debugPrint('Action: Stop current flutter run and start fresh: flutter run');
      debugPrint('============================================================');
    }
  }

  /// Get current FCM Token and persist to local storage & Supabase
  static Future<String?> fetchAndSyncFcmToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        fcmTokenNotifier.value = token;
        await _saveAndSyncToken(token);
        debugPrint('[FCM] Active Device Token: $token');
        return token;
      }
    } catch (e) {
      debugPrint('[FCM] Error fetching token: $e');
    }
    return null;
  }

  /// Save token locally and sync to Supabase user_metadata for server targeting
  static Future<void> _saveAndSyncToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fitvisor_fcm_token', token);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {
            'fcm_token': token,
            'fcm_platform': Platform.operatingSystem,
            'fcm_updated_at': DateTime.now().toIso8601String(),
          }),
        );
        debugPrint('[FCM] Synced token to Supabase user_metadata.');
      }
    } catch (e) {
      debugPrint('[FCM] Token sync warning: $e');
    }
  }
}
