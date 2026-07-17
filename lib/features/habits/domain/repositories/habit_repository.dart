import '../../data/models/habit_model.dart';

abstract class HabitRepository {
  Stream<List<HabitModel>> watchHabits();
  Future<List<HabitModel>> getHabits();
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(int id);
  Future<void> completeHabit(int id);
  Future<void> syncWithCloud();
}
