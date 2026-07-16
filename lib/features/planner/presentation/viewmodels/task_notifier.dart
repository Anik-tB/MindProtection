import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_notifier.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepositoryImpl();
}

@riverpod
class TaskList extends _$TaskList {
  late final TaskRepository _repository;

  @override
  Stream<List<TaskModel>> build() {
    _repository = ref.watch(taskRepositoryProvider);
    return _repository.watchTasks();
  }

  Future<void> addTask(
    String title, {
    String? description,
    required DateTime scheduleTime,
    required String priority,
  }) async {
    final task = TaskModel()
      ..title = title
      ..description = description
      ..scheduleTime = scheduleTime
      ..priority = priority
      ..isCompleted = false;

    await _repository.addTask(task);
  }

  Future<void> toggleTask(int id) async {
    await _repository.toggleTask(id);
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
  }

  Future<void> syncTasks() async {
    await _repository.syncWithCloud();
  }
}
