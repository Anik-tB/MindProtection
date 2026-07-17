import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/sobriety_model.dart';
import '../../domain/repositories/recovery_repository.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  RecoveryRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<SobrietyModel?> watchSobriety() {
    return _isar.sobrietyModels.watchObject(1, fireImmediately: true);
  }

  @override
  Future<SobrietyModel> getOrCreateSobriety() async {
    final status = await _isar.sobrietyModels.get(1);
    if (status != null) {
      // Calculate current streak dynamically in case time passed
      final now = DateTime.now();
      final diffDays = now.difference(status.sobrietyStartDate).inDays;
      if (diffDays != status.currentStreakDays) {
        status.currentStreakDays = diffDays;
        if (diffDays > status.longestStreakDays) {
          status.longestStreakDays = diffDays;
        }
        await _isar.writeTxn(() async {
          await _isar.sobrietyModels.put(status);
        });
        await _syncToCloud(status);
      }
      return status;
    }

    final newStatus = SobrietyModel()
      ..id = 1
      ..sobrietyStartDate = DateTime.now().subtract(const Duration(days: 1)) // 1 day initially for demonstration
      ..currentStreakDays = 1
      ..longestStreakDays = 1
      ..relapseDates = []
      ..triggersLog = [];

    await _isar.writeTxn(() async {
      await _isar.sobrietyModels.put(newStatus);
    });
    await _syncToCloud(newStatus);

    return newStatus;
  }

  @override
  Future<void> logRelapse(String trigger) async {
    final status = await getOrCreateSobriety();
    final now = DateTime.now();

    final relapses = List<DateTime>.from(status.relapseDates ?? []);
    relapses.add(now);
    status.relapseDates = relapses;

    final triggers = List<String>.from(status.triggersLog ?? []);
    triggers.add('Relapse trigger: $trigger');
    status.triggersLog = triggers;

    status.sobrietyStartDate = now;
    status.currentStreakDays = 0;

    await _isar.writeTxn(() async {
      await _isar.sobrietyModels.put(status);
    });
    await _syncToCloud(status);
  }

  @override
  Future<void> logUrge(String trigger) async {
    final status = await getOrCreateSobriety();
    final triggers = List<String>.from(status.triggersLog ?? []);
    triggers.add('Urge triggered by: $trigger at ${DateTime.now().toIso8601String()}');
    status.triggersLog = triggers;

    await _isar.writeTxn(() async {
      await _isar.sobrietyModels.put(status);
    });
    await _syncToCloud(status);
  }

  @override
  Future<void> resetSobriety() async {
    final status = await getOrCreateSobriety();
    status.sobrietyStartDate = DateTime.now();
    status.currentStreakDays = 0;

    await _isar.writeTxn(() async {
      await _isar.sobrietyModels.put(status);
    });
    await _syncToCloud(status);
  }

  Future<void> _syncToCloud(SobrietyModel model) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('sobriety').upsert({
        'id': model.id,
        'user_id': user.id,
        'sobriety_start_date': model.sobrietyStartDate.toIso8601String(),
        'current_streak_days': model.currentStreakDays,
        'longest_streak_days': model.longestStreakDays,
        'relapse_dates': model.relapseDates?.map((e) => e.toIso8601String()).toList(),
        'triggers_log': model.triggersLog,
      });
    } catch (e) {
      debugPrint('Cloud sobriety sync failed: $e');
    }
  }
}
