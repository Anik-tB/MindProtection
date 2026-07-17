import '../../data/models/goal_model.dart';

abstract class GoalRepository {
  // Watch goals reactively from local database (Isar)
  Stream<List<GoalModel>> watchGoals();

  // Get list of goals
  Future<List<GoalModel>> getGoals();

  // Add a goal (saves locally + attempts cloud sync)
  Future<void> addGoal(GoalModel goal);

  // Toggle completion of a goal
  Future<bool> toggleGoal(int id);

  // Delete a goal
  Future<void> deleteGoal(int id);

  // Sync offline goals with Supabase cloud
  Future<void> syncWithCloud();
}
