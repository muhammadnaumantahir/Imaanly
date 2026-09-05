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
}
