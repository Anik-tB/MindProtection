import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/notification_service.dart';

part 'notification_notifier.g.dart';

class NotificationState {
  final bool isPermissionGranted;
  final bool isMorningFocusEnabled;
  final int morningHour;
  final int morningMinute;
  final bool isEveningReflectionEnabled;
  final int eveningHour;
  final int eveningMinute;
  final bool isHydrationNudgeEnabled;
  final bool isStreakWarningEnabled;
  final List<VaultNotificationItem> vaultItems;

  const NotificationState({
    required this.isPermissionGranted,
    required this.isMorningFocusEnabled,
    required this.morningHour,
    required this.morningMinute,
    required this.isEveningReflectionEnabled,
    required this.eveningHour,
    required this.eveningMinute,
    required this.isHydrationNudgeEnabled,
    required this.isStreakWarningEnabled,
    required this.vaultItems,
  });

  NotificationState copyWith({
    bool? isPermissionGranted,
    bool? isMorningFocusEnabled,
    int? morningHour,
    int? morningMinute,
    bool? isEveningReflectionEnabled,
    int? eveningHour,
    int? eveningMinute,
    bool? isHydrationNudgeEnabled,
    bool? isStreakWarningEnabled,
    List<VaultNotificationItem>? vaultItems,
  }) {
    return NotificationState(
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isMorningFocusEnabled: isMorningFocusEnabled ?? this.isMorningFocusEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      isEveningReflectionEnabled: isEveningReflectionEnabled ?? this.isEveningReflectionEnabled,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
      isHydrationNudgeEnabled: isHydrationNudgeEnabled ?? this.isHydrationNudgeEnabled,
      isStreakWarningEnabled: isStreakWarningEnabled ?? this.isStreakWarningEnabled,
      vaultItems: vaultItems ?? this.vaultItems,
    );
  }
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  static const _prefsKeyMorningEnabled = 'notif_morning_enabled';
  static const _prefsKeyMorningHour = 'notif_morning_hour';
  static const _prefsKeyMorningMin = 'notif_morning_min';
  static const _prefsKeyEveningEnabled = 'notif_evening_enabled';
  static const _prefsKeyEveningHour = 'notif_evening_hour';
  static const _prefsKeyEveningMin = 'notif_evening_min';
  static const _prefsKeyHydrationEnabled = 'notif_hydration_enabled';
  static const _prefsKeyStreakEnabled = 'notif_streak_enabled';

  @override
  FutureOr<NotificationState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isGranted = await NotificationService.checkPermission();
    final vaultItems = await NotificationService.getVaultNotifications();

    final isMorningEnabled = prefs.getBool(_prefsKeyMorningEnabled) ?? true;
    final morningHour = prefs.getInt(_prefsKeyMorningHour) ?? 8;
    final morningMin = prefs.getInt(_prefsKeyMorningMin) ?? 0;

    final isEveningEnabled = prefs.getBool(_prefsKeyEveningEnabled) ?? true;
    final eveningHour = prefs.getInt(_prefsKeyEveningHour) ?? 21;
    final eveningMin = prefs.getInt(_prefsKeyEveningMin) ?? 0;

    final isHydrationEnabled = prefs.getBool(_prefsKeyHydrationEnabled) ?? false;
    final isStreakEnabled = prefs.getBool(_prefsKeyStreakEnabled) ?? true;

    // Ensure alarms are scheduled if enabled and permission granted
    if (isGranted) {
      if (isMorningEnabled) {
        NotificationService.scheduleDailyReminder(
          id: 1001,
          title: '🔥 Morning Focus Kickoff',
          body: 'Your protection system is ready. Schedule your deep focus blocks today!',
          hour: morningHour,
          minute: morningMin,
        );
      }
      if (isEveningEnabled) {
        NotificationService.scheduleDailyReminder(
          id: 1002,
          title: '🌙 Evening Wellbeing Review',
          body: 'Take 2 minutes to log your daily progress and protect your streak.',
          hour: eveningHour,
          minute: eveningMin,
        );
      }
    }

    return NotificationState(
      isPermissionGranted: isGranted,
      isMorningFocusEnabled: isMorningEnabled,
      morningHour: morningHour,
      morningMinute: morningMin,
      isEveningReflectionEnabled: isEveningEnabled,
      eveningHour: eveningHour,
      eveningMinute: eveningMin,
      isHydrationNudgeEnabled: isHydrationEnabled,
      isStreakWarningEnabled: isStreakEnabled,
      vaultItems: vaultItems,
    );
  }

  Future<void> checkPermission() async {
    final granted = await NotificationService.checkPermission();
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(isPermissionGranted: granted));
    }
  }

  Future<void> requestPermission() async {
    await NotificationService.requestPermission();
    final granted = await NotificationService.checkPermission();
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(isPermissionGranted: granted));
    }
  }

  Future<void> toggleMorningFocus(bool value) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyMorningEnabled, value);

    if (value) {
      await NotificationService.scheduleDailyReminder(
        id: 1001,
        title: '🔥 Morning Focus Kickoff',
        body: 'Your protection system is ready. Schedule your deep focus blocks today!',
        hour: state.value!.morningHour,
        minute: state.value!.morningMinute,
      );
    } else {
      await NotificationService.cancelReminder(1001);
    }

    state = AsyncValue.data(state.value!.copyWith(isMorningFocusEnabled: value));
  }

  Future<void> setMorningTime(int hour, int minute) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyMorningHour, hour);
    await prefs.setInt(_prefsKeyMorningMin, minute);

    if (state.value!.isMorningFocusEnabled) {
      await NotificationService.scheduleDailyReminder(
        id: 1001,
        title: '🔥 Morning Focus Kickoff',
        body: 'Your protection system is ready. Schedule your deep focus blocks today!',
        hour: hour,
        minute: minute,
      );
    }

    state = AsyncValue.data(
      state.value!.copyWith(morningHour: hour, morningMinute: minute),
    );
  }

  Future<void> toggleEveningReflection(bool value) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyEveningEnabled, value);

    if (value) {
      await NotificationService.scheduleDailyReminder(
        id: 1002,
        title: '🌙 Evening Wellbeing Review',
        body: 'Take 2 minutes to log your daily progress and protect your streak.',
        hour: state.value!.eveningHour,
        minute: state.value!.eveningMinute,
      );
    } else {
      await NotificationService.cancelReminder(1002);
    }

    state = AsyncValue.data(state.value!.copyWith(isEveningReflectionEnabled: value));
  }

  Future<void> setEveningTime(int hour, int minute) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyEveningHour, hour);
    await prefs.setInt(_prefsKeyEveningMin, minute);

    if (state.value!.isEveningReflectionEnabled) {
      await NotificationService.scheduleDailyReminder(
        id: 1002,
        title: '🌙 Evening Wellbeing Review',
        body: 'Take 2 minutes to log your daily progress and protect your streak.',
        hour: hour,
        minute: minute,
      );
    }

    state = AsyncValue.data(
      state.value!.copyWith(eveningHour: hour, eveningMinute: minute),
    );
  }

  Future<void> toggleHydrationNudge(bool value) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyHydrationEnabled, value);
    state = AsyncValue.data(state.value!.copyWith(isHydrationNudgeEnabled: value));
  }

  Future<void> toggleStreakWarning(bool value) async {
    if (!state.hasValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyStreakEnabled, value);
    state = AsyncValue.data(state.value!.copyWith(isStreakWarningEnabled: value));
  }

  Future<void> testInstantNotification() async {
    await NotificationService.showInstantNotification(
      id: 9999,
      title: '🛡️ MindProtection System Active',
      body: 'Your notification access and native reminder engine are operating with 100% precision!',
    );
  }

  Future<void> refreshVault() async {
    if (!state.hasValue) return;
    final items = await NotificationService.getVaultNotifications();
    state = AsyncValue.data(state.value!.copyWith(vaultItems: items));
  }

  Future<void> clearVault() async {
    if (!state.hasValue) return;
    await NotificationService.clearVaultNotifications();
    state = AsyncValue.data(state.value!.copyWith(vaultItems: []));
  }
}
