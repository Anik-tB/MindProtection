import 'package:isar/isar.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;
  
  String? description;
  
  late DateTime scheduleTime;
  
  late String priority; // 'High', 'Medium', 'Low'
  
  late bool isCompleted;
}
