import 'package:shared_preferences/shared_preferences.dart';

class FastingReminderPreferences {
  static const _enabledKey = 'imaanly.fasting.reminder.enabled';
  static const _hourKey = 'imaanly.fasting.reminder.hour';
  static const _minuteKey = 'imaanly.fasting.reminder.minute';

  const FastingReminderPreferences({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  static Future<FastingReminderPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return FastingReminderPreferences(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 19,
      minute: prefs.getInt(_minuteKey) ?? 0,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
  }

  FastingReminderPreferences copyWith({bool? enabled, int? hour, int? minute}) {
    return FastingReminderPreferences(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
