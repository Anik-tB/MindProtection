import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../../core/db/isar_service.dart';
import '../../data/models/routine_model.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'routine_notifier.g.dart';

@riverpod
class RoutineList extends _$RoutineList {
  late final Isar _isar;

  @override
  Stream<List<RoutineModel>> build() {
    _isar = IsarService.instance;
    return _isar.routineModels.where().watch(fireImmediately: true);
  }

  Future<void> addRoutine(String title, String timeOfDay) async {
    final routine = RoutineModel()
      ..title = title
      ..timeOfDay = timeOfDay
      ..isCompleted = false
      ..lastChecked = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.routineModels.put(routine);
    });
  }

  Future<void> toggleRoutine(int id) async {
    final routine = await _isar.routineModels.get(id);
    if (routine == null) return;

    routine.isCompleted = !routine.isCompleted;
    routine.lastChecked = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.routineModels.put(routine);
    });

    if (routine.isCompleted) {
      // Reward XP on routine completion
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(10); // +10 XP
      await gamificationNotifier.addCoins(2); // +2 Coins
    }
  }

  Future<void> deleteRoutine(int id) async {
    await _isar.writeTxn(() async {
      await _isar.routineModels.delete(id);
    });
  }
}
