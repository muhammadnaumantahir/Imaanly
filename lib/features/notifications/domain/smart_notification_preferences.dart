import 'smart_notification.dart';

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
    }
  }

  bool isQuietHour(DateTime now) {
    if (quietStartHour == quietEndHour) return false;
    if (quietStartHour > quietEndHour) {
      return now.hour >= quietStartHour || now.hour < quietEndHour;
    }
    return now.hour >= quietStartHour && now.hour < quietEndHour;
  }
}
