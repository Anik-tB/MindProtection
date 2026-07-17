import 'package:isar/isar.dart';

part 'gamification_model.g.dart';

@collection
class GamificationModel {
  Id id = 1; // Always use ID = 1 for single row configuration

  late int level;

  late int xp;

  late int coins;

  late int focusStreak;

  late int habitStreak;

  DateTime? lastCheckInDate;
}
