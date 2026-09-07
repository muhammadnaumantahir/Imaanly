import '../domain/prayer_notification_preferences.dart';
import '../services/local_notification_service.dart';
import 'prayer_notification_preferences_store.dart';

/// Synchronizes calculated daily prayer times with local reminder alarms.
///
/// The scheduler is deliberately independent from the prayer calculation
/// implementation: callers provide the already calculated five daily prayers.
/// This keeps notification scheduling deterministic and reusable by Home, the
/// prayer-times screen, background refresh and future widgets.
class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    LocalNotificationService? notifications,
    PrayerNotificationPreferencesStore? preferencesStore,
  })  : _notifications = notifications ?? LocalNotificationService.instance,
        _preferencesStore =
            preferencesStore ?? const PrayerNotificationPreferencesStore();

  final LocalNotificationService _notifications;
  final PrayerNotificationPreferencesStore _preferencesStore;

  static const _prayers = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// Replaces all five prayer reminders for the supplied schedule.
  ///
  /// When [preferences] is omitted, the persisted Settings value is loaded
  /// from the device. This prevents the scheduler from silently reverting to
  /// default reminder settings whenever prayer times are refreshed.
  Future<void> synchronize({
    required List<PrayerScheduleNotificationTime> schedule,
    PrayerNotificationPreferences? preferences,
  }) async {
    final effectivePreferences =
        preferences ?? await _preferencesStore.load();

    await _notifications.initialize();

    for (final prayer in _prayers) {
      final item = _find(schedule, prayer);
      if (item == null) continue;

      if (!effectivePreferences.isEnabled(prayer)) {
        await _notifications.cancelPrayerReminder(
          prayerName: prayer,
          prayerAt: item.time,
        );
        continue;
      }

      await _notifications.schedulePrayerReminder(
        prayerName: prayer,
        prayerAt: item.time,
        reminderMinutes: effectivePreferences.reminderMinutes,
        silent: effectivePreferences.silent,
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
