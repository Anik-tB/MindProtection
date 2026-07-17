import 'dart:io';
import 'package:flutter/services.dart';

class VaultNotificationItem {
  final String packageName;
  final String title;
  final String text;
  final DateTime timestamp;

  const VaultNotificationItem({
    required this.packageName,
    required this.title,
    required this.text,
    required this.timestamp,
  });

  factory VaultNotificationItem.fromRaw(String raw) {
    final parts = raw.split('|');
    if (parts.length >= 4) {
      final millis = int.tryParse(parts[3]) ?? DateTime.now().millisecondsSinceEpoch;
      return VaultNotificationItem(
        packageName: parts[0],
        title: parts[1],
        text: parts[2],
        timestamp: DateTime.fromMillisecondsSinceEpoch(millis),
      );
    }
    return VaultNotificationItem(
      packageName: 'Unknown App',
      title: 'Intercepted Notification',
      text: raw,
      timestamp: DateTime.now(),
    );
  }
}

class NotificationService {
  static const MethodChannel _channel = MethodChannel('com.mindprotection.notifications');

  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('checkPermission');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('showInstantNotification', {
        'id': id,
        'title': title,
        'body': body,
      });
    } catch (e) {
      // Ignore on error
    }
  }

  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('scheduleDailyReminder', {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
      });
    } catch (e) {
      // Ignore on error
    }
  }

  static Future<void> cancelReminder(int id) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('cancelReminder', {'id': id});
    } catch (e) {
      // Ignore on error
    }
  }

  static Future<List<VaultNotificationItem>> getVaultNotifications() async {
    if (!Platform.isAndroid) return [];
    try {
      final rawList = await _channel.invokeListMethod<String>('getVaultNotifications');
      if (rawList == null) return [];
      final items = rawList.map((e) => VaultNotificationItem.fromRaw(e)).toList();
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearVaultNotifications() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('clearVaultNotifications');
    } catch (e) {
      // Ignore on error
    }
  }
}
