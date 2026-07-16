import 'package:isar/isar.dart';

part 'focus_session_model.g.dart';

@collection
class FocusSessionModel {
  Id id = Isar.autoIncrement;

  late String subject;
  
  @Index()
  late DateTime startTime;
  
  late int durationMinutes;
  
  late bool isDeepFocus;
  
  late bool isCompleted;
}
