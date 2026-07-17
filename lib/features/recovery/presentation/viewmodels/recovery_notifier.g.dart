// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveryRepositoryHash() =>
    r'12d968fd6fee4e9ae606c53ad17866ca9a46628b';

/// See also [recoveryRepository].
@ProviderFor(recoveryRepository)
final recoveryRepositoryProvider =
    AutoDisposeProvider<RecoveryRepository>.internal(
  recoveryRepository,
  name: r'recoveryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recoveryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecoveryRepositoryRef = AutoDisposeProviderRef<RecoveryRepository>;
String _$recoveryNotifierHash() => r'690d7681894424c03e697d0d5f9ef4f974e0f6a0';

/// See also [RecoveryNotifier].
@ProviderFor(RecoveryNotifier)
final recoveryNotifierProvider =
    AutoDisposeNotifierProvider<RecoveryNotifier, RecoveryState>.internal(
  RecoveryNotifier.new,
  name: r'recoveryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recoveryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecoveryNotifier = AutoDisposeNotifier<RecoveryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
