import 'package:isar/isar.dart';

part 'routine_model.g.dart';

@collection
class RoutineModel {
  Id id = Isar.autoIncrement;

  late String title;

  late String timeOfDay; // 'Morning', 'Study', 'Night'

  late bool isCompleted;

  late DateTime lastChecked;
}
