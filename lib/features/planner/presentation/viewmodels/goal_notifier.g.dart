// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalRepositoryHash() => r'7c13b00f3141ad442559412877d25c64e6398ef8';

/// See also [goalRepository].
@ProviderFor(goalRepository)
final goalRepositoryProvider = AutoDisposeProvider<GoalRepository>.internal(
  goalRepository,
  name: r'goalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GoalRepositoryRef = AutoDisposeProviderRef<GoalRepository>;
String _$goalListHash() => r'66bf1a7b8af82ef6713021bd378440e88e8d33df';

/// See also [GoalList].
@ProviderFor(GoalList)
final goalListProvider =
    AutoDisposeStreamNotifierProvider<GoalList, List<GoalModel>>.internal(
  GoalList.new,
  name: r'goalListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$goalListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoalList = AutoDisposeStreamNotifier<List<GoalModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
