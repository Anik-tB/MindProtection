import '../../data/models/sobriety_model.dart';

abstract class RecoveryRepository {
  Stream<SobrietyModel?> watchSobriety();
  Future<SobrietyModel> getOrCreateSobriety();
  Future<void> logRelapse(String trigger);
  Future<void> logUrge(String trigger);
  Future<void> resetSobriety();
}
