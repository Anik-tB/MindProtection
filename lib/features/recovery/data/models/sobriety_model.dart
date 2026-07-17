import 'package:isar/isar.dart';

part 'sobriety_model.g.dart';

@collection
class SobrietyModel {
  Id id = Isar.autoIncrement;

  late DateTime sobrietyStartDate;

  late int currentStreakDays;

  late int longestStreakDays;

  List<DateTime>? relapseDates;

  List<String>? triggersLog;
}
