// ignore: unnecessary_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/blocking/data/models/screen_time_entry.dart';
import '../../../../features/blocking/data/models/screen_time_model.dart';
import '../../../../features/blocking/data/repositories/screen_time_repository_impl.dart';

part 'screen_time_provider.g.dart';

@riverpod
Future<List<ScreenTimeEntry>> screenTime(ScreenTimeRef ref) async {
  return await ref.watch(screenTimeRepositoryProvider).getDailyUsage();
}

final historicalScreenTimeProvider =
    FutureProvider.family<List<ScreenTimeModel>, int>((ref, daysBack) async {
  return await ref.watch(screenTimeRepositoryProvider).getHistoricalUsage(daysBack);
});
