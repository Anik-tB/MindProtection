import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  TaskRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<TaskModel>> watchTasks() {
    return _isar.taskModels.where().sortByScheduleTimeDesc().watch(fireImmediately: true);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    return await _isar.taskModels.where().sortByScheduleTimeDesc().findAll();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    // 1. Save to local Isar database (auto-increments ID)
    await _isar.writeTxn(() async {
      await _isar.taskModels.put(task);
    });

    // 2. Sync to Supabase Cloud
    await _syncTaskToCloud(task);
  }

  @override
  Future<bool> toggleTask(int id) async {
    final task = await _isar.taskModels.get(id);
    if (task == null) return false;

    task.isCompleted = !task.isCompleted;

    // 1. Update locally
    await _isar.writeTxn(() async {
      await _isar.taskModels.put(task);
    });

    // 2. Sync change to cloud
    await _syncTaskToCloud(task);
    return task.isCompleted;
  }

  @override
  Future<void> deleteTask(int id) async {
    // 1. Delete locally
    await _isar.writeTxn(() async {
      await _isar.taskModels.delete(id);
    });

    // 2. Delete in cloud
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('tasks').delete().eq('id', id);
      } catch (e) {
        // Fail silently on network errors
        debugPrint('Cloud delete failed: $e');
      }
    }
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Pull tasks from Supabase for current user
      final List<dynamic> remoteData = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id);

      // 2. Save remote tasks locally in Isar
      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final title = data['title'] as String;
          final description = data['description'] as String?;
          final scheduleTime = DateTime.parse(data['schedule_time'] as String);
          final priority = data['priority'] as String;
          final isCompleted = data['is_completed'] as bool;

          final task = TaskModel()
            ..id = id
            ..title = title
            ..description = description
            ..scheduleTime = scheduleTime
            ..priority = priority
            ..isCompleted = isCompleted;

          await _isar.taskModels.put(task);
        }
      });

      // 3. Push local changes that are not synced to cloud (upsert)
      final localTasks = await _isar.taskModels.where().findAll();
      for (var task in localTasks) {
        await _supabase.from('tasks').upsert({
          'id': task.id,
          'user_id': user.id,
          'title': task.title,
          'description': task.description,
          'schedule_time': task.scheduleTime.toIso8601String(),
          'priority': task.priority,
          'is_completed': task.isCompleted,
        });
      }
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  // Cloud helper
  Future<void> _syncTaskToCloud(TaskModel task) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Not signed in, skip cloud sync

    try {
      await _supabase.from('tasks').upsert({
        'id': task.id,
        'user_id': user.id,
        'title': task.title,
        'description': task.description,
        'schedule_time': task.scheduleTime.toIso8601String(),
        'priority': task.priority,
        'is_completed': task.isCompleted,
      });
    } catch (e) {
      debugPrint('Cloud upload failed: $e');
    }
  }
}
