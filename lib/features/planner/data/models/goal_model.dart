import 'package:isar/isar.dart';

part 'goal_model.g.dart';

@collection
class GoalModel {
  Id id = Isar.autoIncrement;

  late String title;

  late bool isLongTerm;

  late DateTime targetDate;

  late bool isCompleted;
}
