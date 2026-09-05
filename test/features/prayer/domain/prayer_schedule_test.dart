import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/prayer/domain/prayer_schedule.dart';

void main() {
  test('returns the five daily prayers in worship order', () {
    final coordinates = Coordinates(31.5204, 74.3587);
    final date = DateTime(2026, 9, 5);
    final parameters = CalculationMethodParameters.karachi()
      ..madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes(coordinates, date, parameters);

    final entries = const PrayerScheduleCalculator().calculate(prayerTimes);

    expect(entries.map((entry) => entry.prayer), [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ]);
  });

  test('exposes sunrise separately from the five daily prayers', () {
    final coordinates = Coordinates(31.5204, 74.3587);
    final date = DateTime(2026, 9, 5);
    final parameters = CalculationMethodParameters.karachi()
      ..madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes(coordinates, date, parameters);

    final sunrise = const PrayerScheduleCalculator().sunrise(prayerTimes);

    expect(sunrise.prayer, Prayer.sunrise);
    expect(sunrise.time, prayerTimes.sunrise.toLocal());
  });
}
