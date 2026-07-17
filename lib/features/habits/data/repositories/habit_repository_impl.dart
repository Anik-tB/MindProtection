import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  HabitRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<HabitModel>> watchHabits() {
    return _isar.habitModels.where().watch(fireImmediately: true);
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    return await _isar.habitModels.where().findAll();
  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _isar.writeTxn(() async {
      await _isar.habitModels.put(habit);
    });
    await _syncHabitToCloud(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await _isar.writeTxn(() async {
      await _isar.habitModels.put(habit);
    });
    await _syncHabitToCloud(habit);
  }

  @override
  Future<void> deleteHabit(int id) async {
    await _isar.writeTxn(() async {
      await _isar.habitModels.delete(id);
    });

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('habits').delete().eq('id', id);
      } catch (e) {
        debugPrint('Cloud delete habit failed: $e');
      }
    }
  }

  @override
  Future<void> completeHabit(int id) async {
    final habit = await _isar.habitModels.get(id);
    if (habit == null) return;

    final now = DateTime.now();
    final history = List<DateTime>.from(habit.completionHistory ?? []);
    
    // Check if already completed today
    bool isCompletedToday = false;
    if (habit.lastCompleted != null) {
      final last = habit.lastCompleted!;
      if (last.year == now.year && last.month == now.month && last.day == now.day) {
        isCompletedToday = true;
      }
    }

    if (!isCompletedToday) {
      history.add(now);
      habit.completionHistory = history;

      // Update streaks
      int newStreak = habit.currentStreak;
      if (habit.lastCompleted != null) {
        final last = habit.lastCompleted!;
        final diff = now.difference(DateTime(last.year, last.month, last.day)).inDays;
        if (diff == 1) {
          newStreak += 1;
        } else if (diff > 1) {
          newStreak = 1; // Broke streak, reset to 1
        }
      } else {
        newStreak = 1; // First completion
      }

      habit.currentStreak = newStreak;
      if (newStreak > habit.longestStreak) {
        habit.longestStreak = newStreak;
      }
      habit.lastCompleted = now;

      await _isar.writeTxn(() async {
        await _isar.habitModels.put(habit);
      });
      await _syncHabitToCloud(habit);
    }
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final List<dynamic> remoteData = await _supabase
          .from('habits')
          .select()
          .eq('user_id', user.id);

      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final title = data['title'] as String;
          final description = data['description'] as String?;
          final currentStreak = data['current_streak'] as int;
          final longestStreak = data['longest_streak'] as int;
          final lastCompletedStr = data['last_completed'] as String?;
          final lastCompleted = lastCompletedStr != null ? DateTime.parse(lastCompletedStr) : null;
          
          final List<dynamic> historyList = data['completion_history'] ?? [];
          final history = historyList.map((e) => DateTime.parse(e as String)).toList();

          final habit = HabitModel()
            ..id = id
            ..title = title
            ..description = description
            ..currentStreak = currentStreak
            ..longestStreak = longestStreak
            ..lastCompleted = lastCompleted
            ..completionHistory = history;

          await _isar.habitModels.put(habit);
        }
      });

      // Push local data
      final localHabits = await _isar.habitModels.where().findAll();
      for (var habit in localHabits) {
        await _supabase.from('habits').upsert({
          'id': habit.id,
          'user_id': user.id,
          'title': habit.title,
          'description': habit.description,
          'current_streak': habit.currentStreak,
          'longest_streak': habit.longestStreak,
          'last_completed': habit.lastCompleted?.toIso8601String(),
          'completion_history': habit.completionHistory?.map((e) => e.toIso8601String()).toList(),
        });
      }
    } catch (e) {
      debugPrint('Cloud sync habits failed: $e');
    }
  }

  Future<void> _syncHabitToCloud(HabitModel habit) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('habits').upsert({
        'id': habit.id,
        'user_id': user.id,
        'title': habit.title,
        'description': habit.description,
        'current_streak': habit.currentStreak,
        'longest_streak': habit.longestStreak,
        'last_completed': habit.lastCompleted?.toIso8601String(),
        'completion_history': habit.completionHistory?.map((e) => e.toIso8601String()).toList(),
      });
    } catch (e) {
      debugPrint('Single habit sync failed: $e');
    }
  }
}
