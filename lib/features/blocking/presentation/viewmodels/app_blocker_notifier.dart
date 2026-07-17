import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/android_blocking_service.dart';

part 'app_blocker_notifier.g.dart';

/// Canonical list of popular distracting apps.
const kPopularBlockableApps = [
  (name: 'Instagram',    pkg: 'com.instagram.android'),
  (name: 'TikTok',       pkg: 'com.zhiliaoapp.musically'),
  (name: 'YouTube',      pkg: 'com.google.android.youtube'),
  (name: 'Twitter / X',  pkg: 'com.twitter.android'),
  (name: 'Facebook',     pkg: 'com.facebook.katana'),
  (name: 'Snapchat',     pkg: 'com.snapchat.android'),
  (name: 'Reddit',       pkg: 'com.reddit.frontpage'),
  (name: 'WhatsApp',     pkg: 'com.whatsapp'),
  (name: 'Discord',      pkg: 'com.discord'),
  (name: 'Pinterest',    pkg: 'com.pinterest'),
  (name: 'LinkedIn',     pkg: 'com.linkedin.android'),
  (name: 'Messenger',    pkg: 'com.facebook.orca'),
];

@riverpod
class AppBlocker extends _$AppBlocker {
  @override
  Future<Set<String>> build() async {
    final list = await AndroidBlockingService.getBlockedApps();
    return list.toSet();
  }

  /// Toggle a package in/out of the blocked set and persist immediately.
  Future<void> toggleApp(String packageName) async {
    final current = await future;
    final updated = Set<String>.from(current);
    if (updated.contains(packageName)) {
      updated.remove(packageName);
    } else {
      updated.add(packageName);
    }
    state = AsyncValue.data(updated);
    await AndroidBlockingService.updateBlockedApps(updated.toList());
  }

  /// Add a custom package name and persist.
  Future<void> addCustomApp(String packageName) async {
    if (packageName.trim().isEmpty) return;
    final current = await future;
    final updated = Set<String>.from(current)..add(packageName.trim());
    state = AsyncValue.data(updated);
    await AndroidBlockingService.updateBlockedApps(updated.toList());
  }

  /// Remove any package name and persist.
  Future<void> removeApp(String packageName) async {
    final current = await future;
    final updated = Set<String>.from(current)..remove(packageName);
    state = AsyncValue.data(updated);
    await AndroidBlockingService.updateBlockedApps(updated.toList());
  }

  /// Return the saved blocked set (used by Focus Timer).
  Future<List<String>> getBlockedList() async {
    final current = await future;
    return current.toList();
  }
}
