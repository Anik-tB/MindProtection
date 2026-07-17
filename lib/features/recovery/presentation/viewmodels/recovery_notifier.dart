import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/sobriety_model.dart';
import '../../data/repositories/recovery_repository_impl.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../../../blocking/data/services/android_blocking_service.dart';

part 'recovery_notifier.g.dart';

class RecoveryState {
  final SobrietyModel? sobriety;
  final bool isAdultBlockerActive;
  final bool isShortsBlockerActive;
  final bool isAppLimiterActive;
  final bool isEmergencyLockActive;

  RecoveryState({
    this.sobriety,
    required this.isAdultBlockerActive,
    required this.isShortsBlockerActive,
    required this.isAppLimiterActive,
    required this.isEmergencyLockActive,
  });

  RecoveryState copyWith({
    SobrietyModel? sobriety,
    bool? isAdultBlockerActive,
    bool? isShortsBlockerActive,
    bool? isAppLimiterActive,
    bool? isEmergencyLockActive,
  }) {
    return RecoveryState(
      sobriety: sobriety ?? this.sobriety,
      isAdultBlockerActive: isAdultBlockerActive ?? this.isAdultBlockerActive,
      isShortsBlockerActive: isShortsBlockerActive ?? this.isShortsBlockerActive,
      isAppLimiterActive: isAppLimiterActive ?? this.isAppLimiterActive,
      isEmergencyLockActive: isEmergencyLockActive ?? this.isEmergencyLockActive,
    );
  }
}

@riverpod
RecoveryRepository recoveryRepository(RecoveryRepositoryRef ref) {
  return RecoveryRepositoryImpl();
}

@riverpod
class RecoveryNotifier extends _$RecoveryNotifier {
  late final RecoveryRepository _repository;

  @override
  RecoveryState build() {
    _repository = ref.watch(recoveryRepositoryProvider);
    _loadInitialSobriety();
    
    return RecoveryState(
      sobriety: null,
      isAdultBlockerActive: true,
      isShortsBlockerActive: true,
      isAppLimiterActive: false,
      isEmergencyLockActive: false,
    );
  }

  Future<void> _loadInitialSobriety() async {
    final sob = await _repository.getOrCreateSobriety();
    state = state.copyWith(sobriety: sob);
    
    // Listen to changes
    _repository.watchSobriety().listen((event) {
      state = state.copyWith(sobriety: event);
    });
  }

  void _syncBlockingState() {
    final List<String> blockedPackages = [];
    
    if (state.isShortsBlockerActive) {
      blockedPackages.addAll([
        'com.google.android.youtube',
        'com.instagram.android',
        'com.zhiliaoapp.musically',
        'com.facebook.katana',
        'com.snapchat.android',
      ]);
    }
    
    if (state.isAdultBlockerActive) {
      blockedPackages.addAll([
        'com.android.chrome',
        'com.sec.android.app.sbrowser',
        'org.mozilla.firefox',
        'com.opera.browser',
      ]);
    }

    AndroidBlockingService.updateBlockedApps(blockedPackages);

    if (state.isAdultBlockerActive || state.isShortsBlockerActive || state.isAppLimiterActive) {
      AndroidBlockingService.startForegroundService();
    } else {
      AndroidBlockingService.stopForegroundService();
    }
  }

  Future<void> toggleAdultBlocker() async {
    state = state.copyWith(isAdultBlockerActive: !state.isAdultBlockerActive);
    _syncBlockingState();
  }

  Future<void> toggleShortsBlocker() async {
    state = state.copyWith(isShortsBlockerActive: !state.isShortsBlockerActive);
    _syncBlockingState();
  }

  Future<void> toggleAppLimiter() async {
    state = state.copyWith(isAppLimiterActive: !state.isAppLimiterActive);
    _syncBlockingState();
  }

  Future<void> setEmergencyLock(bool active) async {
    state = state.copyWith(isEmergencyLockActive: active);
    AndroidBlockingService.setFocusActive(active);
    if (active) {
      AndroidBlockingService.triggerEmergencyLock();
    }
  }

  Future<void> reportRelapse(String trigger) async {
    await _repository.logRelapse(trigger);
    
    // Reset streak on gamification
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    await gamificationNotifier.resetHabitStreak(); // reset streak multiplier
  }

  Future<void> reportUrge(String trigger) async {
    await _repository.logUrge(trigger);
    
    // Reward user XP for reporting the urge instead of giving in
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    await gamificationNotifier.addXp(20); // +20 XP for discipline
    await gamificationNotifier.addCoins(5);
  }
}
