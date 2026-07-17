import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../../core/db/isar_service.dart';
import '../../data/models/goal_model.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'goal_notifier.g.dart';

@riverpod
class GoalList extends _$GoalList {
  late final Isar _isar;

  @override
  Stream<List<GoalModel>> build() {
    _isar = IsarService.instance;
    return _isar.goalModels.where().watch(fireImmediately: true);
  }

  Future<void> addGoal(String title, bool isLongTerm, DateTime targetDate) async {
    final goal = GoalModel()
      ..title = title
      ..isLongTerm = isLongTerm
      ..targetDate = targetDate
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.goalModels.put(goal);
    });
  }

  Future<void> toggleGoal(int id) async {
    final goal = await _isar.goalModels.get(id);
    if (goal == null) return;

    goal.isCompleted = !goal.isCompleted;

    await _isar.writeTxn(() async {
      await _isar.goalModels.put(goal);
    });

    if (goal.isCompleted) {
      // Reward XP on goal completion
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(goal.isLongTerm ? 100 : 30); // Long-term = 100 XP, Short-term = 30 XP
      await gamificationNotifier.addCoins(goal.isLongTerm ? 50 : 10);
    }
  }

  Future<void> deleteGoal(int id) async {
    await _isar.writeTxn(() async {
      await _isar.goalModels.delete(id);
    });
  }
}
