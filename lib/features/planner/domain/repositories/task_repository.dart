import '../../data/models/task_model.dart';

abstract class TaskRepository {
  // Watch tasks reactively from local database (Isar)
  Stream<List<TaskModel>> watchTasks();

  // Get list of tasks
  Future<List<TaskModel>> getTasks();

  // Add a task (saves locally + attempts cloud sync)
  Future<void> addTask(TaskModel task);

  // Toggle completion of a task
  Future<bool> toggleTask(int id);

  // Delete a task
  Future<void> deleteTask(int id);

  // Sync offline tasks with Supabase cloud
  Future<void> syncWithCloud();
}
