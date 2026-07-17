/// Immutable data class representing one app's screen usage for today.
class ScreenTimeEntry {
  final String packageName;
  final String appName;
  final int usageMinutes;

  const ScreenTimeEntry({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });

  factory ScreenTimeEntry.fromMap(Map<String, dynamic> map) {
    return ScreenTimeEntry(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? map['packageName'] as String? ?? '',
      usageMinutes: map['usageMinutes'] as int? ?? 0,
    );
  }
}
