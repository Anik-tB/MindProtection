import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/wellbeing_model.dart';
import '../../domain/repositories/wellbeing_repository.dart';

class WellbeingRepositoryImpl implements WellbeingRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  WellbeingRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<WellbeingLogModel?> watchTodayLog() {
    final today = _getTodayDateOnly();
    return _isar.wellbeingLogModels
        .filter()
        .dateEqualTo(today)
        .watch(fireImmediately: true)
        .map((logs) => logs.isNotEmpty ? logs.first : null);
  }

  @override
  Future<WellbeingLogModel> getOrCreateTodayLog() async {
    final today = _getTodayDateOnly();
    final log = await _isar.wellbeingLogModels.filter().dateEqualTo(today).findFirst();
    if (log != null) return log;

    // Create a new log for today
    final newLog = WellbeingLogModel()
      ..waterIntakeLiters = 0.0
      ..sleepDurationHours = 0.0
      ..moodRating = 3
      ..date = today;

    await _isar.writeTxn(() async {
      await _isar.wellbeingLogModels.put(newLog);
    });
    await _syncLogToCloud(newLog);

    return newLog;
  }

  @override
  Future<void> updateWater(double liters) async {
    final log = await getOrCreateTodayLog();
    log.waterIntakeLiters = liters;

    await _isar.writeTxn(() async {
      await _isar.wellbeingLogModels.put(log);
    });
    await _syncLogToCloud(log);
  }

  @override
  Future<void> updateSleep(double hours) async {
    final log = await getOrCreateTodayLog();
    log.sleepDurationHours = hours;

    await _isar.writeTxn(() async {
      await _isar.wellbeingLogModels.put(log);
    });
    await _syncLogToCloud(log);
  }

  @override
  Future<void> updateMood(int rating) async {
    final log = await getOrCreateTodayLog();
    log.moodRating = rating;

    await _isar.writeTxn(() async {
      await _isar.wellbeingLogModels.put(log);
    });
    await _syncLogToCloud(log);
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final List<dynamic> remoteData = await _supabase
          .from('wellbeing_logs')
          .select()
          .eq('user_id', user.id);

      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final water = (data['water_intake_liters'] as num).toDouble();
          final sleep = (data['sleep_duration_hours'] as num).toDouble();
          final mood = data['mood_rating'] as int;
          final date = DateTime.parse(data['date'] as String);

          final log = WellbeingLogModel()
            ..id = id
            ..waterIntakeLiters = water
            ..sleepDurationHours = sleep
            ..moodRating = mood
            ..date = date;

          await _isar.wellbeingLogModels.put(log);
        }
      });

      // Push local data
      final localLogs = await _isar.wellbeingLogModels.where().findAll();
      for (var log in localLogs) {
        await _supabase.from('wellbeing_logs').upsert({
          'id': log.id,
          'user_id': user.id,
          'water_intake_liters': log.waterIntakeLiters,
          'sleep_duration_hours': log.sleepDurationHours,
          'mood_rating': log.moodRating,
          'date': log.date.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Cloud sync wellbeing logs failed: $e');
    }
  }

  Future<void> _syncLogToCloud(WellbeingLogModel log) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('wellbeing_logs').upsert({
        'id': log.id,
        'user_id': user.id,
        'water_intake_liters': log.waterIntakeLiters,
        'sleep_duration_hours': log.sleepDurationHours,
        'mood_rating': log.moodRating,
        'date': log.date.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Single wellbeing log sync failed: $e');
    }
  }

  DateTime _getTodayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
