import 'smart_notification_category.dart';

/// User-controlled local notification policy.
///
/// These preferences contain no account, network, or cloud state.
class SmartNotificationPreferences {
  const SmartNotificationPreferences({
    this.prayerEnabled = true,
    this.quranEnabled = true,
    this.dhikrEnabled = true,
    this.streakEnabled = true,
    this.maxNotificationsPerDay = 1,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
  });

  final bool prayerEnabled;
  final bool quranEnabled;
  final bool dhikrEnabled;
  final bool streakEnabled;
  final int maxNotificationsPerDay;
  final int quietStartHour;
  final int quietEndHour;

  bool isEnabled(SmartNotificationCategory category) {
    switch (category) {
      case SmartNotificationCategory.prayer:
        return prayerEnabled;
      case SmartNotificationCategory.quran:
        return quranEnabled;
      case SmartNotificationCategory.dhikr:
        return dhikrEnabled;
      case SmartNotificationCategory.streak:
        return streakEnabled;
    }
  }

  bool isQuietHour(DateTime now) {
    if (quietStartHour == quietEndHour) return false;
    if (quietStartHour > quietEndHour) {
      return now.hour >= quietStartHour || now.hour < quietEndHour;
    }
    return now.hour >= quietStartHour && now.hour < quietEndHour;
  }

  SmartNotificationPreferences copyWith({
    bool? prayerEnabled,
    bool? quranEnabled,
    bool? dhikrEnabled,
    bool? streakEnabled,
    int? maxNotificationsPerDay,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return SmartNotificationPreferences(
      prayerEnabled: prayerEnabled ?? this.prayerEnabled,
      quranEnabled: quranEnabled ?? this.quranEnabled,
      dhikrEnabled: dhikrEnabled ?? this.dhikrEnabled,
      streakEnabled: streakEnabled ?? this.streakEnabled,
      maxNotificationsPerDay:
          maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }

  Map<String, dynamic> toMap() => {
        'prayerEnabled': prayerEnabled,
        'quranEnabled': quranEnabled,
        'dhikrEnabled': dhikrEnabled,
        'streakEnabled': streakEnabled,
        'maxNotificationsPerDay': maxNotificationsPerDay,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
      };

  factory SmartNotificationPreferences.fromMap(Map<dynamic, dynamic> map) {
    int readInt(String key, int fallback) {
      final value = map[key];
      return value is num ? value.toInt() : fallback;
    }

    bool readBool(String key, bool fallback) {
      final value = map[key];
      return value is bool ? value : fallback;
    }

    return SmartNotificationPreferences(
      prayerEnabled: readBool('prayerEnabled', true),
      quranEnabled: readBool('quranEnabled', true),
      dhikrEnabled: readBool('dhikrEnabled', true),
      streakEnabled: readBool('streakEnabled', true),
      maxNotificationsPerDay:
          readInt('maxNotificationsPerDay', 1).clamp(0, 10).toInt(),
      quietStartHour: readInt('quietStartHour', 22).clamp(0, 23).toInt(),
      quietEndHour: readInt('quietEndHour', 7).clamp(0, 23).toInt(),
    );
  }
}
