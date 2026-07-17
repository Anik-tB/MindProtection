import '../../data/models/focus_session_model.dart';

abstract class FocusRepository {
  Stream<List<FocusSessionModel>> watchFocusSessions();
  Future<List<FocusSessionModel>> getFocusSessions();
  Future<void> addFocusSession(FocusSessionModel session);
  Future<void> syncWithCloud();
}
