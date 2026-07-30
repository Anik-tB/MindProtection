import 'dart:convert';
import 'package:isar/isar.dart';

import '../db/isar_service.dart';
import '../../features/focus/data/models/focus_session_model.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/planner/data/models/task_model.dart';
import '../../features/recovery/data/models/sobriety_model.dart';
import '../../features/wellbeing/data/models/wellbeing_model.dart';

class DataExportService {
  /// Compiles complete user data snapshot into a JSON string
  static Future<String> generateCompleteJsonBackup() async {
    final isar = IsarService.instance;

    final focusSessions = await isar.focusSessionModels.where().findAll();
    final habits = await isar.habitModels.where().findAll();
    final tasks = await isar.taskModels.where().findAll();
    final sobriety = await isar.sobrietyModels.where().findFirst();
    final wellbeingLogs = await isar.wellbeingLogModels.where().findAll();

    final exportMap = {
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0+1',
      'sobriety_data': sobriety != null
          ? {
              'current_streak_days': sobriety.currentStreakDays,
              'longest_streak_days': sobriety.longestStreakDays,
              'sobriety_start_date': sobriety.sobrietyStartDate.toIso8601String(),
              'triggers_log': sobriety.triggersLog ?? [],
            }
          : null,
      'focus_sessions': focusSessions
          .map((s) => {
                'id': s.id,
                'subject': s.subject,
                'duration_minutes': s.durationMinutes,
                'start_time': s.startTime.toIso8601String(),
                'is_completed': s.isCompleted,
                'is_deep_focus': s.isDeepFocus,
              })
          .toList(),
      'habits': habits
          .map((h) => {
                'id': h.id,
                'title': h.title,
                'description': h.description,
                'current_streak': h.currentStreak,
                'longest_streak': h.longestStreak,
                'last_completed': h.lastCompleted?.toIso8601String(),
                'completion_history': h.completionHistory
                    ?.map((d) => d.toIso8601String())
                    .toList() ?? [],
              })
          .toList(),
      'tasks': tasks
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'is_completed': t.isCompleted,
                'priority': t.priority,
                'schedule_time': t.scheduleTime.toIso8601String(),
              })
          .toList(),
      'wellbeing_logs': wellbeingLogs
          .map((w) => {
                'date': w.date.toIso8601String(),
                'water_intake_liters': w.waterIntakeLiters,
                'sleep_duration_hours': w.sleepDurationHours,
                'mood_rating': w.moodRating,
                'mindful_minutes': w.mindfulMinutes,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Generates human-readable CSV format of Focus Sessions
  static Future<String> generateFocusCsvReport() async {
    final isar = IsarService.instance;
    final sessions = await isar.focusSessionModels.where().findAll();

    final sb = StringBuffer();
    sb.writeln('ID,Subject,Mode,DurationMinutes,StartTime,Completed');

    for (final s in sessions) {
      final mode = s.isDeepFocus ? 'Deep Focus' : 'Standard Focus';
      sb.writeln(
        '${s.id},"${s.subject}",$mode,${s.durationMinutes},${s.startTime.toIso8601String()},${s.isCompleted}',
      );
    }

    return sb.toString();
  }
}
