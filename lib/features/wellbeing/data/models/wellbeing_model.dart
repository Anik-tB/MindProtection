import 'package:isar/isar.dart';

part 'wellbeing_model.g.dart';

@collection
class WellbeingLogModel {
  Id id = Isar.autoIncrement;

  late double waterIntakeLiters;

  late double sleepDurationHours;

  late int moodRating; // 1 to 5 scale

  @Index()
  late DateTime date;
}
