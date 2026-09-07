import '../domain/prayer_notification_preferences.dart';
import '../services/local_notification_service.dart';

/// Synchronizes calculated daily prayer times with local reminder alarms.
///
/// The scheduler is deliberately independent from the prayer calculation
/// implementation: callers provide the already calculated five daily prayers.
/// This keeps notification scheduling deterministic and reusable by Home, the
/// prayer-times screen, background refresh and future widgets.
class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    LocalNotificationService? notifications,
  }) : _notifications = notifications ?? LocalNotificationService.instance;

  final LocalNotificationService _notifications;

  static const _prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// Replaces all five prayer reminders for the supplied schedule.
  ///
  /// Disabled prayers are explicitly cancelled so changing a preference does
  /// not leave an old alarm on the device. Past occurrences are ignored by the
  /// platform service. When [preferences] are omitted, all five prayers are
  /// enabled with the default 10-minute reminder and normal sound.
  Future<void> synchronize({
    required List<PrayerScheduleNotificationTime> schedule,
    PrayerNotificationPreferences preferences =
        const PrayerNotificationPreferences(),
  }) async {
    await _notifications.initialize();

    for (final prayer in _prayers) {
      final item = _find(schedule, prayer);
      if (item == null) continue;

      if (!preferences.isEnabled(prayer)) {
        await _notifications.cancelPrayerReminder(
          prayerName: prayer,
          prayerAt: item.time,
        );
        continue;
      }

      await _notifications.schedulePrayerReminder(
        prayerName: prayer,
        prayerAt: item.time,
        reminderMinutes: preferences.reminderMinutes,
        silent: preferences.silent,
      );
    }
  }

  PrayerScheduleNotificationTime? _find(
    List<PrayerScheduleNotificationTime> schedule,
    String name,
  ) {
    for (final item in schedule) {
      if (item.prayerName.toLowerCase() == name.toLowerCase()) return item;
    }
    return null;
  }
}

/// Small adapter model so the notification layer does not depend on UI types.
class PrayerScheduleNotificationTime {
  const PrayerScheduleNotificationTime({
    required this.prayerName,
    required this.time,
  });

  final String prayerName;
  final DateTime time;
}
