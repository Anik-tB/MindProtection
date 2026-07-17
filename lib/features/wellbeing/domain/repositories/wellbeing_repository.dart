import '../../data/models/wellbeing_model.dart';

abstract class WellbeingRepository {
  Stream<WellbeingLogModel?> watchTodayLog();
  Future<WellbeingLogModel> getOrCreateTodayLog();
  Future<void> updateWater(double liters);
  Future<void> updateSleep(double hours);
  Future<void> updateMood(int rating);
  Future<void> updateMindfulness(int minutes);
  Future<void> syncWithCloud();
}
