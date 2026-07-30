import 'package:flutter/services.dart';

class AndroidBlockingService {
  static const MethodChannel _channel = MethodChannel('com.mindprotection.blocking');

  /// Checks if Usage Stats Access permission is granted
  static Future<bool> checkUsageStatsPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('checkUsageStatsPermission');
      return granted;
    } on PlatformException {
      return false;
    }
  }

  /// Directs the user to Usage Access Settings
  static Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Checks if the Accessibility Service is active
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final bool enabled = await _channel.invokeMethod('checkAccessibilityPermission');
      return enabled;
    } on PlatformException {
      return false;
    }
  }

  /// Directs the user to Accessibility Settings
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Checks if the Notification Interceptor is active
  static Future<bool> checkNotificationListenerPermission() async {
    try {
      final bool enabled = await _channel.invokeMethod('checkNotificationListenerPermission');
      return enabled;
    } on PlatformException {
      return false;
    }
  }

  /// Directs the user to Notification Settings
  static Future<void> requestNotificationListenerPermission() async {
    try {
      await _channel.invokeMethod('requestNotificationListenerPermission');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Checks if Device Admin status is active
  static Future<bool> checkDeviceAdminActive() async {
    try {
      final bool active = await _channel.invokeMethod('checkDeviceAdminActive');
      return active;
    } on PlatformException {
      return false;
    }
  }

  /// Prompts user to enable Device Administrator access
  static Future<void> requestDeviceAdminPermission() async {
    try {
      await _channel.invokeMethod('requestDeviceAdminPermission');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Pushes a list of package names to the native accessibility blocking service
  static Future<void> updateBlockedApps(List<String> packages) async {
    try {
      await _channel.invokeMethod('updateBlockedApps', {'packages': packages});
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Saves focus state flag (read by notification and accessibility blockers)
  static Future<void> setFocusActive(bool active) async {
    try {
      await _channel.invokeMethod('setFocusActive', {'active': active});
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Triggers full device lock
  static Future<void> triggerEmergencyLock() async {
    try {
      await _channel.invokeMethod('triggerEmergencyLock');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Sets Anti-Uninstall Protection flag in native Accessibility Service
  static Future<void> setAntiUninstallActive(bool active) async {
    try {
      await _channel.invokeMethod('setAntiUninstallActive', {'active': active});
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Sets OS Settings Protection flag in native Accessibility Service
  static Future<void> setSettingGuardActive(bool active) async {
    try {
      await _channel.invokeMethod('setSettingGuardActive', {'active': active});
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Starts the Wellbeing Foreground Service
  static Future<void> startForegroundService() async {
    try {
      await _channel.invokeMethod('startForegroundService');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Stops the Wellbeing Foreground Service
  static Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (_) {
      // Catch exceptions silently
    }
  }

  /// Returns a list of per-app usage stats for today (requires Usage Stats permission)
  /// Each entry contains: packageName (String), appName (String), usageMinutes (int)
  static Future<List<Map<String, dynamic>>> getUsageStats() async {
    try {
      final List<dynamic> raw = await _channel.invokeMethod('getUsageStats');
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  /// Returns the currently persisted list of blocked package names
  static Future<List<String>> getBlockedApps() async {
    try {
      final List<dynamic> raw = await _channel.invokeMethod('getBlockedApps');
      return raw.cast<String>();
    } on PlatformException {
      return [];
    }
  }
}
