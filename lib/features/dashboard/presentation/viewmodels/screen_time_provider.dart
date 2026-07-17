import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/blocking/data/models/screen_time_entry.dart';
import '../../../../features/blocking/data/services/android_blocking_service.dart';

part 'screen_time_provider.g.dart';

@riverpod
Future<List<ScreenTimeEntry>> screenTime(ScreenTimeRef ref) async {
  final raw = await AndroidBlockingService.getUsageStats();
  return raw.map(ScreenTimeEntry.fromMap).toList();
}
