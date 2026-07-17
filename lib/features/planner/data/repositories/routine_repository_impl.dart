import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/routine_model.dart';
import '../../domain/repositories/routine_repository.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  RoutineRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<RoutineModel>> watchRoutines() {
    return _isar.routineModels.where().watch(fireImmediately: true);
  }

  @override
  Future<List<RoutineModel>> getRoutines() async {
    return await _isar.routineModels.where().findAll();
  }

  @override
  Future<void> addRoutine(RoutineModel routine) async {
    await _isar.writeTxn(() async {
      await _isar.routineModels.put(routine);
    });

    await _syncRoutineToCloud(routine);
  }

  @override
  Future<bool> toggleRoutine(int id) async {
    final routine = await _isar.routineModels.get(id);
    if (routine == null) return false;

    routine.isCompleted = !routine.isCompleted;
    routine.lastChecked = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.routineModels.put(routine);
    });

    await _syncRoutineToCloud(routine);
    return routine.isCompleted;
  }

  @override
  Future<void> deleteRoutine(int id) async {
    await _isar.writeTxn(() async {
      await _isar.routineModels.delete(id);
    });

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('routines').delete().eq('id', id);
      } catch (e) {
        debugPrint('Cloud routine delete failed: $e');
      }
    }
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Pull routines from Supabase for current user
      final List<dynamic> remoteData = await _supabase
          .from('routines')
          .select()
          .eq('user_id', user.id);

      // 2. Save remote routines locally in Isar
      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final title = data['title'] as String;
          final timeOfDay = data['time_of_day'] as String;
          final isCompleted = data['is_completed'] as bool;
          final lastCheckedStr = data['last_checked'] as String?;
          final lastChecked = lastCheckedStr != null
              ? DateTime.tryParse(lastCheckedStr) ?? DateTime.now()
              : DateTime.now();

          final routine = RoutineModel()
            ..id = id
            ..title = title
            ..timeOfDay = timeOfDay
            ..isCompleted = isCompleted
            ..lastChecked = lastChecked;

          await _isar.routineModels.put(routine);
        }
      });

      // 3. Push local routines to cloud
      final localRoutines = await _isar.routineModels.where().findAll();
      for (var r in localRoutines) {
        await _supabase.from('routines').upsert({
          'id': r.id,
          'user_id': user.id,
          'title': r.title,
          'time_of_day': r.timeOfDay,
          'is_completed': r.isCompleted,
          'last_checked': r.lastChecked.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Routine syncWithCloud error: $e');
    }
  }

  Future<void> _syncRoutineToCloud(RoutineModel routine) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('routines').upsert({
        'id': routine.id,
        'user_id': user.id,
        'title': routine.title,
        'time_of_day': routine.timeOfDay,
        'is_completed': routine.isCompleted,
        'last_checked': routine.lastChecked.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Routine cloud sync failed: $e');
    }
  }
}
