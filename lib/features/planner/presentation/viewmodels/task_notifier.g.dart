// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRepositoryHash() => r'07b4d1d8e043937f963e52f66b966b9aaa3cebc5';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$taskListHash() => r'd69bbbb079accfda702b34021518ab21f3802db3';

/// See also [TaskList].
@ProviderFor(TaskList)
final taskListProvider =
    AutoDisposeStreamNotifierProvider<TaskList, List<TaskModel>>.internal(
  TaskList.new,
  name: r'taskListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskList = AutoDisposeStreamNotifier<List<TaskModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
