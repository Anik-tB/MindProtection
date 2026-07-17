import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'goal_notifier.g.dart';

@riverpod
GoalRepository goalRepository(GoalRepositoryRef ref) {
  return GoalRepositoryImpl();
}

@riverpod
class GoalList extends _$GoalList {
  late final GoalRepository _repository;

  @override
  Stream<List<GoalModel>> build() {
    _repository = ref.watch(goalRepositoryProvider);
    return _repository.watchGoals();
  }

  Future<void> addGoal(String title, bool isLongTerm, DateTime targetDate) async {
    final goal = GoalModel()
      ..title = title
      ..isLongTerm = isLongTerm
      ..targetDate = targetDate
      ..isCompleted = false;

    await _repository.addGoal(goal);
  }

  Future<void> toggleGoal(int id) async {
    final existingGoal = state.value?.where((g) => g.id == id).firstOrNull;
    final isLongTerm = existingGoal?.isLongTerm ?? false;

    final isCompleted = await _repository.toggleGoal(id);
    if (isCompleted) {
      // Reward XP on goal completion
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(isLongTerm ? 100 : 30);
      await gamificationNotifier.addCoins(isLongTerm ? 50 : 10);
    }
  }

  Future<void> deleteGoal(int id) async {
    await _repository.deleteGoal(id);
  }
}
