import 'package:isar/isar.dart';

part 'habit_model.g.dart';

@collection
class HabitModel {
  Id id = Isar.autoIncrement;

  late String title;
  
  String? description;
  
  late int currentStreak;
  
  late int longestStreak;
  
  DateTime? lastCompleted;
  
  List<DateTime>? completionHistory;
}
