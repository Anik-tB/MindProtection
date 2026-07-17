// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routineRepositoryHash() => r'387e6ef6cda1ee0251883eca1ff714285291f0b0';

/// See also [routineRepository].
@ProviderFor(routineRepository)
final routineRepositoryProvider =
    AutoDisposeProvider<RoutineRepository>.internal(
  routineRepository,
  name: r'routineRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routineRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoutineRepositoryRef = AutoDisposeProviderRef<RoutineRepository>;
String _$routineListHash() => r'6dbcdbaa66de608ee90742db5bd3580dd89aa355';

/// See also [RoutineList].
@ProviderFor(RoutineList)
final routineListProvider =
    AutoDisposeStreamNotifierProvider<RoutineList, List<RoutineModel>>.internal(
  RoutineList.new,
  name: r'routineListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routineListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoutineList = AutoDisposeStreamNotifier<List<RoutineModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
