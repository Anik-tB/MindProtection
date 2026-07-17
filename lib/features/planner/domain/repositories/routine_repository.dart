import '../../data/models/routine_model.dart';

abstract class RoutineRepository {
  // Watch routines reactively from local database (Isar)
  Stream<List<RoutineModel>> watchRoutines();

  // Get list of routines
  Future<List<RoutineModel>> getRoutines();

  // Add a routine (saves locally + attempts cloud sync)
  Future<void> addRoutine(RoutineModel routine);

  // Toggle completion of a routine
  Future<bool> toggleRoutine(int id);

  // Delete a routine
  Future<void> deleteRoutine(int id);

  // Sync offline routines with Supabase cloud
  Future<void> syncWithCloud();
}
