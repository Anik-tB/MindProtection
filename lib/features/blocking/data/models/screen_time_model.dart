import 'package:isar/isar.dart';

part 'screen_time_model.g.dart';

@collection
class ScreenTimeModel {
  Id id = Isar.autoIncrement;

  late String packageName;
  
  late String appName;
  
  late int usageMinutes;
  
  late DateTime date;
}
