import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/focus/data/models/focus_session_model.dart';
import '../../features/planner/data/models/task_model.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/blocking/data/models/screen_time_model.dart';

class IsarService {
  static Isar? _instance;

  static Isar get instance {
    if (_instance == null) {
      throw StateError('Isar database is not initialized yet. Call init() first.');
    }
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _instance = await Isar.open(
      [
        FocusSessionModelSchema,
        TaskModelSchema,
        HabitModelSchema,
        ScreenTimeModelSchema,
      ],
      directory: dir.path,
    );
  }

  // Generic helpers for quick access
  static Future<void> clearAll() async {
    final isar = instance;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
