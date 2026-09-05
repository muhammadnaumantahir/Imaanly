import 'package:adhan_dart/adhan_dart.dart';

/// A small, UI-independent representation of the next prayer.
class NextPrayer {
  const NextPrayer({
    required this.prayer,
    required this.time,
    required this.remaining,
  });

  final Prayer prayer;
  final DateTime time;
  final Duration remaining;
}

/// Calculates the next prayer from an already-calculated [PrayerTimes].
///
/// Keeping this decision outside the widget makes the Home experience easy to
/// test and prevents countdown/UI code from becoming responsible for the
/// astronomical calculation itself.
class NextPrayerCalculator {
  const NextPrayerCalculator();

  NextPrayer? calculate(PrayerTimes prayerTimes, DateTime now) {
    final prayers = <Prayer>[
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (final prayer in prayers) {
      final time = prayerTimes.timeForPrayer(prayer).toLocal();
      if (time.isAfter(now)) {
        return NextPrayer(
          prayer: prayer,
          time: time,
          remaining: time.difference(now),
        );
      }
    }

    // After Isha, the next prayer is tomorrow's Fajr. Adhan Dart exposes the
    // following day's Fajr specifically for this wrap-around case.
    final tomorrow = prayerTimes.fajrAfter.toLocal();
    return NextPrayer(
      prayer: Prayer.fajr,
      time: tomorrow,
      remaining: tomorrow.difference(now),
    );
  }
}
