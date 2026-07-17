import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/wellbeing_model.dart';
import '../../data/repositories/wellbeing_repository_impl.dart';
import '../../domain/repositories/wellbeing_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'wellbeing_notifier.g.dart';

@riverpod
WellbeingRepository wellbeingRepository(WellbeingRepositoryRef ref) {
  return WellbeingRepositoryImpl();
}

@riverpod
Stream<WellbeingLogModel?> todayWellbeingLog(TodayWellbeingLogRef ref) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchTodayLog();
}

@riverpod
class WellbeingNotifier extends _$WellbeingNotifier {
  late final WellbeingRepository _repository;

  @override
  Future<WellbeingLogModel> build() async {
    _repository = ref.watch(wellbeingRepositoryProvider);
    return await _repository.getOrCreateTodayLog();
  }

  Future<void> addWater(double liters) async {
    final currentLog = await _repository.getOrCreateTodayLog();
    final double newWater = currentLog.waterIntakeLiters + liters;
    await _repository.updateWater(newWater);

    // Rewards
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    if (currentLog.waterIntakeLiters == 0 && newWater > 0) {
      await gamificationNotifier.addXp(5); // +5 XP for starting water intake
    }
    if (currentLog.waterIntakeLiters < 2.0 && newWater >= 2.0) {
      await gamificationNotifier.addXp(15); // +15 XP for reaching 2.0L target
      await gamificationNotifier.addCoins(5);
    }
  }

  Future<void> updateSleep(double hours) async {
    final currentLog = await _repository.getOrCreateTodayLog();
    await _repository.updateSleep(hours);

    // Reward healthy sleep log (7 to 9 hours)
    if (currentLog.sleepDurationHours == 0 && hours >= 7.0 && hours <= 9.0) {
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(15);
      await gamificationNotifier.addCoins(5);
    }
  }

  Future<void> logMood(int rating) async {
    final currentLog = await _repository.getOrCreateTodayLog();
    await _repository.updateMood(rating);

    // Reward mood log
    if (currentLog.moodRating == 3 && rating != 3) {
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(5);
    }
  }

  Future<void> logMindfulness(int minutes) async {
    final currentLog = await _repository.getOrCreateTodayLog();
    final newMinutes = currentLog.mindfulMinutes + minutes;
    await _repository.updateMindfulness(newMinutes);

    // Reward mindful minutes
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    await gamificationNotifier.addXp(minutes * 5); // +5 XP per mindful minute
    if (minutes >= 2) {
      await gamificationNotifier.addCoins(minutes * 2);
    }
  }

  Future<void> syncWellbeing() async {
    await _repository.syncWithCloud();
  }
}
