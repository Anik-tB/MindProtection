import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/planner/presentation/viewmodels/task_notifier.dart';
import '../../features/planner/presentation/viewmodels/routine_notifier.dart';
import '../../features/planner/presentation/viewmodels/goal_notifier.dart';
import '../../features/habits/presentation/viewmodels/habit_notifier.dart';
import '../../features/focus/presentation/viewmodels/focus_timer_notifier.dart';
import '../../features/recovery/presentation/viewmodels/recovery_notifier.dart';
import '../../features/wellbeing/presentation/viewmodels/wellbeing_notifier.dart';

part 'cloud_sync_notifier.g.dart';

class CloudSyncState {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? lastError;
  final int syncedRepositoriesCount;
  final int totalRepositories;

  const CloudSyncState({
    required this.isSyncing,
    this.lastSyncedAt,
    this.lastError,
    this.syncedRepositoriesCount = 0,
    this.totalRepositories = 7,
  });

  CloudSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? lastError,
    int? syncedRepositoriesCount,
    int? totalRepositories,
  }) {
    return CloudSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError,
      syncedRepositoriesCount: syncedRepositoriesCount ?? this.syncedRepositoriesCount,
      totalRepositories: totalRepositories ?? this.totalRepositories,
    );
  }
}

@Riverpod(keepAlive: true)
class CloudSyncNotifier extends _$CloudSyncNotifier {
  @override
  CloudSyncState build() {
    return const CloudSyncState(isSyncing: false);
  }

  Future<bool> syncAllRepositories() async {
    if (state.isSyncing) return false;

    state = state.copyWith(
      isSyncing: true,
      syncedRepositoriesCount: 0,
      lastError: null,
    );

    int count = 0;
    try {
      // 1. Sync Tasks
      await ref.read(taskRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 2. Sync Routines
      await ref.read(routineRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 3. Sync Goals
      await ref.read(goalRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 4. Sync Habits
      await ref.read(habitRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 5. Sync Focus Sessions
      await ref.read(focusRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 6. Sync Recovery (Sobriety)
      await ref.read(recoveryRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(syncedRepositoriesCount: count);

      // 7. Sync Wellbeing Logs
      await ref.read(wellbeingRepositoryProvider).syncWithCloud();
      count++;
      state = state.copyWith(
        isSyncing: false,
        syncedRepositoriesCount: count,
        lastSyncedAt: DateTime.now(),
      );
      return true;
    } catch (e) {
      debugPrint('CloudSyncNotifier error: $e');
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
      return false;
    }
  }
}
