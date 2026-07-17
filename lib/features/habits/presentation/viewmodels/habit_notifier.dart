import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'habit_notifier.g.dart';

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepositoryImpl();
}

@riverpod
Stream<List<HabitModel>> habitList(HabitListRef ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabits();
}

@riverpod
class HabitListNotifier extends _$HabitListNotifier {
  late final HabitRepository _repository;

  @override
  Stream<List<HabitModel>> build() {
    _repository = ref.watch(habitRepositoryProvider);
    return _repository.watchHabits();
  }

  Future<void> addHabit(String title, {String? description}) async {
    final habit = HabitModel()
      ..title = title
      ..description = description
      ..currentStreak = 0
      ..longestStreak = 0
      ..completionHistory = [];

    await _repository.addHabit(habit);
  }

  Future<int> completeHabit(int id) async {
    final newStreak = await _repository.completeHabit(id);

    // Reward XP and Coins on completing a habit
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    await gamificationNotifier.addXp(15); // +15 XP
    await gamificationNotifier.addCoins(5); // +5 Coins
    await gamificationNotifier.incrementHabitStreak();

    // Bonus rewards on milestone streaks (3, 7, 14, 30 days)
    if ([3, 7, 14, 30, 60, 100].contains(newStreak)) {
      await gamificationNotifier.addXp(newStreak * 5); // extra bonus XP
      await gamificationNotifier.addCoins(newStreak * 2); // extra bonus Coins
    }

    return newStreak;
  }

  Future<void> deleteHabit(int id) async {
    await _repository.deleteHabit(id);
  }

  Future<void> syncHabits() async {
    await _repository.syncWithCloud();
  }
}
