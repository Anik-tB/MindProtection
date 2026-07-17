import '../../data/models/screen_time_entry.dart';
import '../../data/models/screen_time_model.dart';

abstract class ScreenTimeRepository {
  /// Fetches today's app usage stats (syncs live native Android data to Isar and returns entries)
  Future<List<ScreenTimeEntry>> getDailyUsage();

  /// Fetches historical usage stored in Isar database within [daysBack] days
  Future<List<ScreenTimeModel>> getHistoricalUsage(int daysBack);

  /// Manually saves usage entries into local Isar vault for today
  Future<void> saveDailyUsage(List<ScreenTimeEntry> entries);

  /// Synchronizes local Isar screen time logs with Supabase [screen_times] cloud vault
  Future<void> syncWithCloud();
}
