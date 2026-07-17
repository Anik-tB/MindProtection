import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/focus_session_model.dart';
import '../../data/repositories/focus_repository_impl.dart';
import '../../domain/repositories/focus_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../../../blocking/data/services/android_blocking_service.dart';

part 'focus_timer_notifier.g.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}

enum FocusMode {
  pomodoro,
  shortBreak,
  longBreak,
  custom,
  stopwatch,
}

class FocusTimerState {
  final int durationSecondsRemaining;
  final int totalDurationSeconds;
  final TimerStatus status;
  final FocusMode mode;
  final String subject;
  final bool isDeepFocus;

  FocusTimerState({
    required this.durationSecondsRemaining,
    required this.totalDurationSeconds,
    required this.status,
    required this.mode,
    required this.subject,
    required this.isDeepFocus,
  });

  FocusTimerState copyWith({
    int? durationSecondsRemaining,
    int? totalDurationSeconds,
    TimerStatus? status,
    FocusMode? mode,
    String? subject,
    bool? isDeepFocus,
  }) {
    return FocusTimerState(
      durationSecondsRemaining: durationSecondsRemaining ?? this.durationSecondsRemaining,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      subject: subject ?? this.subject,
      isDeepFocus: isDeepFocus ?? this.isDeepFocus,
    );
  }
}

@riverpod
FocusRepository focusRepository(FocusRepositoryRef ref) {
  return FocusRepositoryImpl();
}

@riverpod
Stream<List<FocusSessionModel>> focusSessionList(FocusSessionListRef ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.watchFocusSessions();
}

@riverpod
class FocusTimer extends _$FocusTimer {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return FocusTimerState(
      durationSecondsRemaining: 1500, // 25 minutes
      totalDurationSeconds: 1500,
      status: TimerStatus.idle,
      mode: FocusMode.pomodoro,
      subject: 'General',
      isDeepFocus: false,
    );
  }

  void setMode(FocusMode mode) {
    _timer?.cancel();
    int seconds = 0;
    switch (mode) {
      case FocusMode.pomodoro:
        seconds = 1500; // 25 mins
        break;
      case FocusMode.shortBreak:
        seconds = 300; // 5 mins
        break;
      case FocusMode.longBreak:
        seconds = 900; // 15 mins
        break;
      case FocusMode.custom:
        seconds = 1800; // 30 mins initial
        break;
      case FocusMode.stopwatch:
        seconds = 0; // starts at 0 and ticks up
        break;
    }

    state = state.copyWith(
      mode: mode,
      status: TimerStatus.idle,
      totalDurationSeconds: seconds,
      durationSecondsRemaining: seconds,
    );
  }

  void setCustomDuration(int seconds) {
    if (state.mode != FocusMode.custom) return;
    _timer?.cancel();
    state = state.copyWith(
      status: TimerStatus.idle,
      totalDurationSeconds: seconds,
      durationSecondsRemaining: seconds,
    );
  }

  void setSubject(String subject) {
    state = state.copyWith(subject: subject);
  }

  void toggleDeepFocus() {
    state = state.copyWith(isDeepFocus: !state.isDeepFocus);
  }

  void start() {
    if (state.status == TimerStatus.running) return;
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.running);
    AndroidBlockingService.setFocusActive(true);
    if (state.isDeepFocus) {
      AndroidBlockingService.getBlockedApps().then((list) {
        if (list.isEmpty) {
          const defaults = [
            'com.instagram.android',
            'com.zhiliaoapp.musically',
            'com.google.android.youtube',
            'com.twitter.android',
            'com.facebook.katana',
          ];
          AndroidBlockingService.updateBlockedApps(defaults);
        }
      });
    }
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
    AndroidBlockingService.setFocusActive(false);
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;
    state = state.copyWith(status: TimerStatus.running);
    AndroidBlockingService.setFocusActive(true);
    if (state.isDeepFocus) {
      AndroidBlockingService.getBlockedApps().then((list) {
        if (list.isEmpty) {
          const defaults = [
            'com.instagram.android',
            'com.zhiliaoapp.musically',
            'com.google.android.youtube',
            'com.twitter.android',
            'com.facebook.katana',
          ];
          AndroidBlockingService.updateBlockedApps(defaults);
        }
      });
    }
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      status: TimerStatus.idle,
      durationSecondsRemaining: state.totalDurationSeconds,
    );
    AndroidBlockingService.setFocusActive(false);
  }

  Future<void> finishStopwatch() async {
    AndroidBlockingService.setFocusActive(false);
    if (state.mode != FocusMode.stopwatch || state.durationSecondsRemaining <= 10) {
      // Don't save empty/too short session
      _timer?.cancel();
      state = state.copyWith(status: TimerStatus.idle, durationSecondsRemaining: 0);
      return;
    }

    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.completed);

    final durationSeconds = state.durationSecondsRemaining;
    final minutes = durationSeconds ~/ 60;
    
    final session = FocusSessionModel()
      ..subject = state.subject.trim().isEmpty ? 'General' : state.subject
      ..startTime = DateTime.now().subtract(Duration(seconds: durationSeconds))
      ..durationMinutes = minutes > 0 ? minutes : 1
      ..isDeepFocus = state.isDeepFocus
      ..isCompleted = true;

    await ref.read(focusRepositoryProvider).addFocusSession(session);

    // Gamification reward
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    final xpEarned = (durationSeconds ~/ 60) * 2 + 5; // 2 XP per minute + 5 base
    await gamificationNotifier.addXp(xpEarned);
    await gamificationNotifier.addCoins(durationSeconds ~/ 120); // 1 coin per 2 minutes
    await gamificationNotifier.incrementFocusStreak();

    state = state.copyWith(status: TimerStatus.idle, durationSecondsRemaining: 0);
  }

  Future<void> _tick(Timer timer) async {
    if (state.mode == FocusMode.stopwatch) {
      state = state.copyWith(
        durationSecondsRemaining: state.durationSecondsRemaining + 1,
      );
      return;
    }

    if (state.durationSecondsRemaining > 0) {
      state = state.copyWith(
        durationSecondsRemaining: state.durationSecondsRemaining - 1,
      );
    } else {
      _timer?.cancel();
      AndroidBlockingService.setFocusActive(false);
      state = state.copyWith(status: TimerStatus.completed);

      // Save focus session
      if (state.mode == FocusMode.pomodoro || state.mode == FocusMode.custom) {
        final session = FocusSessionModel()
          ..subject = state.subject.trim().isEmpty ? 'General' : state.subject
          ..startTime = DateTime.now().subtract(Duration(seconds: state.totalDurationSeconds))
          ..durationMinutes = state.totalDurationSeconds ~/ 60
          ..isDeepFocus = state.isDeepFocus
          ..isCompleted = true;

        await ref.read(focusRepositoryProvider).addFocusSession(session);

        // Gamification reward
        final gamificationNotifier = ref.read(gamificationProvider.notifier);
        final xpEarned = (state.totalDurationSeconds ~/ 60) * 2 + 10; // 2 XP per minute + 10 base
        await gamificationNotifier.addXp(xpEarned);
        await gamificationNotifier.addCoins(state.totalDurationSeconds ~/ 120); // 1 coin per 2 minutes
        await gamificationNotifier.incrementFocusStreak();
      }
    }
  }
}
