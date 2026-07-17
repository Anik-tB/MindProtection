import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/routine_model.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

part 'routine_notifier.g.dart';

@riverpod
RoutineRepository routineRepository(RoutineRepositoryRef ref) {
  return RoutineRepositoryImpl();
}

@riverpod
class RoutineList extends _$RoutineList {
  late final RoutineRepository _repository;

  @override
  Stream<List<RoutineModel>> build() {
    _repository = ref.watch(routineRepositoryProvider);
    return _repository.watchRoutines();
  }

  Future<void> addRoutine(String title, String timeOfDay) async {
    final routine = RoutineModel()
      ..title = title
      ..timeOfDay = timeOfDay
      ..isCompleted = false
      ..lastChecked = DateTime.now();

    await _repository.addRoutine(routine);
  }

  Future<void> toggleRoutine(int id) async {
    final isCompleted = await _repository.toggleRoutine(id);
    if (isCompleted) {
      // Reward XP on routine completion
      final gamificationNotifier = ref.read(gamificationProvider.notifier);
      await gamificationNotifier.addXp(10); // +10 XP
      await gamificationNotifier.addCoins(2); // +2 Coins
    }
  }

  Future<void> deleteRoutine(int id) async {
    await _repository.deleteRoutine(id);
  }
}
