// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellbeing_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wellbeingRepositoryHash() =>
    r'3940e1e3f23e82bbf92524c6e50951fd7b929b5a';

/// See also [wellbeingRepository].
@ProviderFor(wellbeingRepository)
final wellbeingRepositoryProvider =
    AutoDisposeProvider<WellbeingRepository>.internal(
  wellbeingRepository,
  name: r'wellbeingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wellbeingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WellbeingRepositoryRef = AutoDisposeProviderRef<WellbeingRepository>;
String _$todayWellbeingLogHash() => r'3cc7d111ec9db9362ed6db95fb83fbb8fff16926';

/// See also [todayWellbeingLog].
@ProviderFor(todayWellbeingLog)
final todayWellbeingLogProvider =
    AutoDisposeStreamProvider<WellbeingLogModel?>.internal(
  todayWellbeingLog,
  name: r'todayWellbeingLogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayWellbeingLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayWellbeingLogRef = AutoDisposeStreamProviderRef<WellbeingLogModel?>;
String _$wellbeingNotifierHash() => r'6c38a98cf00c7adb33e1c3e45f5fe0ad2dd17803';

/// See also [WellbeingNotifier].
@ProviderFor(WellbeingNotifier)
final wellbeingNotifierProvider = AutoDisposeAsyncNotifierProvider<
    WellbeingNotifier, WellbeingLogModel>.internal(
  WellbeingNotifier.new,
  name: r'wellbeingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wellbeingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WellbeingNotifier = AutoDisposeAsyncNotifier<WellbeingLogModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
