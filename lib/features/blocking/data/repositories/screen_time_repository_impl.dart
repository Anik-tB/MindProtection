// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/db/isar_service.dart';
import '../../domain/repositories/screen_time_repository.dart';
import '../models/screen_time_entry.dart';
import '../models/screen_time_model.dart';
import '../services/android_blocking_service.dart';

final screenTimeRepositoryProvider = Provider<ScreenTimeRepository>((ref) {
  return ScreenTimeRepositoryImpl(
    isar: IsarService.instance,
    supabase: Supabase.instance.client,
  );
});

class ScreenTimeRepositoryImpl implements ScreenTimeRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  ScreenTimeRepositoryImpl({
    required Isar isar,
    required SupabaseClient supabase,
  })  : _isar = isar,
        _supabase = supabase;

  @override
  Future<List<ScreenTimeEntry>> getDailyUsage() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      // 1. Attempt to fetch live usage stats from native Android UsageStatsManager
      final raw = await AndroidBlockingService.getUsageStats();
      if (raw.isNotEmpty) {
        final entries = raw.map(ScreenTimeEntry.fromMap).toList();
        
        // Save/update today's records in Isar offline vault
        await saveDailyUsage(entries);
        return entries;
      }
    } catch (e) {
      debugPrint('ScreenTime getDailyUsage native check failed: $e');
    }

    // 2. Fallback to Isar offline cache if native check returns empty or fails
    final localModels = await _isar.screenTimeModels
        .filter()
        .dateEqualTo(today)
        .sortByUsageMinutesDesc()
        .findAll();

    return localModels
        .map((m) => ScreenTimeEntry(
              packageName: m.packageName,
              appName: m.appName,
              usageMinutes: m.usageMinutes,
            ))
        .toList();
  }

  @override
  Future<List<ScreenTimeModel>> getHistoricalUsage(int daysBack) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysBack));

    return await _isar.screenTimeModels
        .filter()
        .dateGreaterThan(cutoff, include: true)
        .sortByDateDesc()
        .thenByUsageMinutesDesc()
        .findAll();
  }

  @override
  Future<void> saveDailyUsage(List<ScreenTimeEntry> entries) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _isar.writeTxn(() async {
      for (final entry in entries) {
        if (entry.usageMinutes <= 0 || entry.packageName.isEmpty) continue;

        final existing = await _isar.screenTimeModels
            .filter()
            .packageNameEqualTo(entry.packageName)
            .and()
            .dateEqualTo(today)
            .findFirst();

        if (existing != null) {
          existing.usageMinutes = entry.usageMinutes;
          existing.appName = entry.appName;
          await _isar.screenTimeModels.put(existing);
        } else {
          final model = ScreenTimeModel()
            ..packageName = entry.packageName
            ..appName = entry.appName
            ..usageMinutes = entry.usageMinutes
            ..date = today;
          await _isar.screenTimeModels.put(model);
        }
      }
    });
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Pull historical screen times from Supabase cloud vault for current user
      final List<dynamic> remoteData = await _supabase
          .from('screen_times')
          .select()
          .eq('user_id', user.id);

      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final pkg = data['package_name'] as String? ?? '';
          if (pkg.isEmpty) continue;

          final appName = data['app_name'] as String? ?? pkg;
          final usageMin = data['usage_minutes'] as int? ?? 0;
          final dateStr = data['date'] as String?;
          final date = dateStr != null
              ? (DateTime.tryParse(dateStr) ?? DateTime.now())
              : DateTime.now();
          final cleanDate = DateTime(date.year, date.month, date.day);

          final existing = await _isar.screenTimeModels
              .filter()
              .packageNameEqualTo(pkg)
              .and()
              .dateEqualTo(cleanDate)
              .findFirst();

          if (existing != null) {
            if (usageMin > existing.usageMinutes) {
              existing.usageMinutes = usageMin;
              await _isar.screenTimeModels.put(existing);
            }
          } else {
            final model = ScreenTimeModel()
              ..packageName = pkg
              ..appName = appName
              ..usageMinutes = usageMin
              ..date = cleanDate;
            await _isar.screenTimeModels.put(model);
          }
        }
      });

      // 2. Push local screen times to Supabase cloud vault
      final localModels = await _isar.screenTimeModels.where().findAll();
      for (var model in localModels) {
        await _supabase.from('screen_times').upsert({
          'user_id': user.id,
          'package_name': model.packageName,
          'app_name': model.appName,
          'usage_minutes': model.usageMinutes,
          'date': model.date.toIso8601String().split('T').first,
        });
      }
    } catch (e) {
      debugPrint('ScreenTime syncWithCloud error: $e');
    }
  }
}
