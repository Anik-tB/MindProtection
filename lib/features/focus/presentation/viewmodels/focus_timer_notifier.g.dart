// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$focusRepositoryHash() => r'fc50ba1dff4964aea8ed0fa60d59a37feb3d3b23';

/// See also [focusRepository].
@ProviderFor(focusRepository)
final focusRepositoryProvider = AutoDisposeProvider<FocusRepository>.internal(
  focusRepository,
  name: r'focusRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$focusRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FocusRepositoryRef = AutoDisposeProviderRef<FocusRepository>;
String _$focusSessionListHash() => r'2bfe7f1be29387e3acca2471bd138c1782ced9e8';

/// See also [focusSessionList].
@ProviderFor(focusSessionList)
final focusSessionListProvider =
    AutoDisposeStreamProvider<List<FocusSessionModel>>.internal(
  focusSessionList,
  name: r'focusSessionListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$focusSessionListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FocusSessionListRef
    = AutoDisposeStreamProviderRef<List<FocusSessionModel>>;
String _$focusTimerHash() => r'77ba47cb2e3178ae4dae6ec5ca81a7578ab680e1';

/// See also [FocusTimer].
@ProviderFor(FocusTimer)
final focusTimerProvider =
    AutoDisposeNotifierProvider<FocusTimer, FocusTimerState>.internal(
  FocusTimer.new,
  name: r'focusTimerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$focusTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FocusTimer = AutoDisposeNotifier<FocusTimerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
