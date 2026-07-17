// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitRepositoryHash() => r'f7a46012c6b571e0e019842b5947962abd6e3990';

/// See also [habitRepository].
@ProviderFor(habitRepository)
final habitRepositoryProvider = AutoDisposeProvider<HabitRepository>.internal(
  habitRepository,
  name: r'habitRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HabitRepositoryRef = AutoDisposeProviderRef<HabitRepository>;
String _$habitListHash() => r'4d2d81547eab9d3a564669d0685e754e709a2977';

/// See also [habitList].
@ProviderFor(habitList)
final habitListProvider = AutoDisposeStreamProvider<List<HabitModel>>.internal(
  habitList,
  name: r'habitListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HabitListRef = AutoDisposeStreamProviderRef<List<HabitModel>>;
String _$habitListNotifierHash() => r'14da0bfcd0004a64f78075133ace0aa29607f8dc';

/// See also [HabitListNotifier].
@ProviderFor(HabitListNotifier)
final habitListNotifierProvider = AutoDisposeStreamNotifierProvider<
    HabitListNotifier, List<HabitModel>>.internal(
  HabitListNotifier.new,
  name: r'habitListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitListNotifier = AutoDisposeStreamNotifier<List<HabitModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
