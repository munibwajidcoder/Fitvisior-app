import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to show real native Android OS push notifications on the device status bar
/// with sound, vibration, heads-up banner, and launcher icon badging
class SystemNotificationService {
  static const MethodChannel _channel = MethodChannel('com.fitvisor.app/notifications');

  /// Displays real Android system notification on the phone's notification bar
  static Future<void> showNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('showSystemNotification', {
          'title': title,
          'body': body,
          'id': id ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
        });
        debugPrint('[SystemNotificationService] Triggered native system notification: "$title"');
      }
    } catch (e) {
      debugPrint('[SystemNotificationService] System notification notice: $e');
    }
  }
}
