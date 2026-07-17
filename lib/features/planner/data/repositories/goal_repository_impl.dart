import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/goal_model.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  GoalRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<GoalModel>> watchGoals() {
    return _isar.goalModels.where().watch(fireImmediately: true);
  }

  @override
  Future<List<GoalModel>> getGoals() async {
    return await _isar.goalModels.where().findAll();
  }

  @override
  Future<void> addGoal(GoalModel goal) async {
    await _isar.writeTxn(() async {
      await _isar.goalModels.put(goal);
    });

    await _syncGoalToCloud(goal);
  }

  @override
  Future<bool> toggleGoal(int id) async {
    final goal = await _isar.goalModels.get(id);
    if (goal == null) return false;

    goal.isCompleted = !goal.isCompleted;

    await _isar.writeTxn(() async {
      await _isar.goalModels.put(goal);
    });

    await _syncGoalToCloud(goal);
    return goal.isCompleted;
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _isar.writeTxn(() async {
      await _isar.goalModels.delete(id);
    });

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('goals').delete().eq('id', id);
      } catch (e) {
        debugPrint('Cloud goal delete failed: $e');
      }
    }
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Pull goals from Supabase for current user
      final List<dynamic> remoteData = await _supabase
          .from('goals')
          .select()
          .eq('user_id', user.id);

      // 2. Save remote goals locally in Isar
      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final title = data['title'] as String;
          final isLongTerm = data['is_long_term'] as bool;
          final targetDateStr = data['target_date'] as String;
          final targetDate = DateTime.tryParse(targetDateStr) ?? DateTime.now();
          final isCompleted = data['is_completed'] as bool;

          final goal = GoalModel()
            ..id = id
            ..title = title
            ..isLongTerm = isLongTerm
            ..targetDate = targetDate
            ..isCompleted = isCompleted;

          await _isar.goalModels.put(goal);
        }
      });

      // 3. Push local goals to cloud
      final localGoals = await _isar.goalModels.where().findAll();
      for (var g in localGoals) {
        await _supabase.from('goals').upsert({
          'id': g.id,
          'user_id': user.id,
          'title': g.title,
          'is_long_term': g.isLongTerm,
          'target_date': g.targetDate.toIso8601String(),
          'is_completed': g.isCompleted,
        });
      }
    } catch (e) {
      debugPrint('Goal syncWithCloud error: $e');
    }
  }

  Future<void> _syncGoalToCloud(GoalModel goal) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('goals').upsert({
        'id': goal.id,
        'user_id': user.id,
        'title': goal.title,
        'is_long_term': goal.isLongTerm,
        'target_date': goal.targetDate.toIso8601String(),
        'is_completed': goal.isCompleted,
      });
    } catch (e) {
      debugPrint('Goal cloud sync failed: $e');
    }
  }
}
