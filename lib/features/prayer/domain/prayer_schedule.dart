import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:imaanly/src/screen/prayer_time/models/prayer_enum.dart';

/// A display-ready prayer entry derived from an Adhan Dart [adhan.PrayerTimes].
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

  List<PrayerScheduleEntry> calculate(adhan.PrayerTimes prayerTimes) {
    return [
      for (final prayer in _dailyPrayers)
        PrayerScheduleEntry(
          prayer: prayer,
          time: prayerTimes.timeForPrayer(_toAdhanPrayer(prayer)).toLocal(),
        ),
    ];
  }

  PrayerScheduleEntry sunrise(adhan.PrayerTimes prayerTimes) {
    return PrayerScheduleEntry(
      prayer: Prayer.sunrise,
      time: prayerTimes.sunrise.toLocal(),
    );
  }

  /// Builds the next day's Fajr entry from an already calculated day.
  ///
  /// [PrayerTimes.fajrAfter] is the Fajr after the date represented by the
  /// supplied object. Therefore, when callers already pass tomorrow's
  /// [PrayerTimes], its [fajr] is the correct next-day Fajr for the current
  /// day's schedule.
  PrayerScheduleEntry nextDayFajr(adhan.PrayerTimes nextDayPrayerTimes) {
    return PrayerScheduleEntry(
      prayer: Prayer.fajr,
      time: nextDayPrayerTimes.fajr.toLocal(),
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

  static adhan.Prayer _toAdhanPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return adhan.Prayer.fajr;
      case Prayer.dhuhr:
        return adhan.Prayer.dhuhr;
      case Prayer.asr:
        return adhan.Prayer.asr;
      case Prayer.maghrib:
        return adhan.Prayer.maghrib;
      case Prayer.isha:
        return adhan.Prayer.isha;
      case Prayer.sunrise:
      case Prayer.dhuha:
      case Prayer.noon:
      case Prayer.sunset:
      case Prayer.tahajjud:
      case Prayer.none:
        throw ArgumentError('Prayer $prayer is not part of the five-prayer schedule');
    }
  }
}
