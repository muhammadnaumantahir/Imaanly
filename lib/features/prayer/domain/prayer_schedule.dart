import 'package:adhan_dart/adhan_dart.dart';

/// A display-ready prayer entry derived from an Adhan Dart [PrayerTimes].
class PrayerScheduleEntry {
  const PrayerScheduleEntry({
    required this.prayer,
    required this.time,
  });

  final Prayer prayer;
  final DateTime time;
}

/// Provides one canonical daily schedule for the Imaanly prayer experience.
///
/// Calculation parameters and location remain the responsibility of the
/// existing prayer/location layers. This class only turns calculated times
/// into a stable, ordered model reusable by Home, Prayer Times, notifications
/// and future widgets.
class PrayerScheduleCalculator {
  const PrayerScheduleCalculator();

  static const _dailyPrayers = <Prayer>[
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  List<PrayerScheduleEntry> calculate(PrayerTimes prayerTimes) {
    return [
      for (final prayer in _dailyPrayers)
        PrayerScheduleEntry(
          prayer: prayer,
          time: prayerTimes.timeForPrayer(prayer).toLocal(),
        ),
    ];
  }

  PrayerScheduleEntry sunrise(PrayerTimes prayerTimes) {
    return PrayerScheduleEntry(
      prayer: Prayer.sunrise,
      time: prayerTimes.sunrise.toLocal(),
    );
  }

  /// Builds the next day's Fajr entry from an already calculated day.
  ///
  /// Keeping this behavior here prevents individual UI surfaces from
  /// implementing subtly different after-Isha logic.
  PrayerScheduleEntry nextDayFajr(PrayerTimes nextDayPrayerTimes) {
    return PrayerScheduleEntry(
      prayer: Prayer.fajr,
      time: nextDayPrayerTimes.fajrAfter.toLocal(),
    );
  }

  /// Returns the prayer whose interval has started and whose next prayer has
  /// not started yet. Before Fajr there is no current prayer in today's list.
  PrayerScheduleEntry? current(
    List<PrayerScheduleEntry> entries,
    DateTime now,
  ) {
    PrayerScheduleEntry? result;
    for (final entry in entries) {
      if (!entry.time.isAfter(now)) {
        result = entry;
      } else {
        break;
      }
    }
    return result;
  }

  /// Returns the first prayer strictly after [now]. After Isha, callers can
  /// use [nextDayFajr] with the following day's PrayerTimes model.
  PrayerScheduleEntry? next(
    List<PrayerScheduleEntry> entries,
    DateTime now,
  ) {
    for (final entry in entries) {
      if (entry.time.isAfter(now)) {
        return entry;
      }
    }
    return null;
  }
}
