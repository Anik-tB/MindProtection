import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/db/isar_service.dart';
import '../models/focus_session_model.dart';
import '../../domain/repositories/focus_repository.dart';

class FocusRepositoryImpl implements FocusRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  FocusRepositoryImpl({Isar? isar, SupabaseClient? supabase})
      : _isar = isar ?? IsarService.instance,
        _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<FocusSessionModel>> watchFocusSessions() {
    return _isar.focusSessionModels
        .where()
        .sortByStartTimeDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessions() async {
    return await _isar.focusSessionModels
        .where()
        .sortByStartTimeDesc()
        .findAll();
  }

  @override
  Future<void> addFocusSession(FocusSessionModel session) async {
    // 1. Save to local Isar database
    await _isar.writeTxn(() async {
      await _isar.focusSessionModels.put(session);
    });

    // 2. Sync to Supabase Cloud
    await _syncSessionToCloud(session);
  }

  @override
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Pull focus sessions from Supabase for current user
      final List<dynamic> remoteData = await _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', user.id);

      // 2. Save remote focus sessions locally in Isar
      await _isar.writeTxn(() async {
        for (var data in remoteData) {
          final id = data['id'] as int;
          final subject = data['subject'] as String;
          final startTime = DateTime.parse(data['start_time'] as String);
          final durationMinutes = data['duration_minutes'] as int;
          final isDeepFocus = data['is_deep_focus'] as bool;
          final isCompleted = data['is_completed'] as bool;

          final session = FocusSessionModel()
            ..id = id
            ..subject = subject
            ..startTime = startTime
            ..durationMinutes = durationMinutes
            ..isDeepFocus = isDeepFocus
            ..isCompleted = isCompleted;

          await _isar.focusSessionModels.put(session);
        }
      });

      // 3. Push local changes that are not synced to cloud (upsert)
      final localSessions = await _isar.focusSessionModels.where().findAll();
      for (var session in localSessions) {
        await _supabase.from('focus_sessions').upsert({
          'id': session.id,
          'user_id': user.id,
          'subject': session.subject,
          'start_time': session.startTime.toIso8601String(),
          'duration_minutes': session.durationMinutes,
          'is_deep_focus': session.isDeepFocus,
          'is_completed': session.isCompleted,
        });
      }
    } catch (e) {
      // Fail silently on network errors/missing table
      debugPrint('Cloud focus sync failed: $e');
    }
  }

  // Cloud helper
  Future<void> _syncSessionToCloud(FocusSessionModel session) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Not signed in, skip cloud sync

    try {
      await _supabase.from('focus_sessions').upsert({
        'id': session.id,
        'user_id': user.id,
        'subject': session.subject,
        'start_time': session.startTime.toIso8601String(),
        'duration_minutes': session.durationMinutes,
        'is_deep_focus': session.isDeepFocus,
        'is_completed': session.isCompleted,
      });
    } catch (e) {
      // Fail silently on network errors/missing table
      debugPrint('Cloud focus upload failed: $e');
    }
  }
}
