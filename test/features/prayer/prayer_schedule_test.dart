import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/prayer/domain/prayer_schedule.dart';

void main() {
  test('builds the five daily prayers in chronological order', () {
    final date = DateTime(2026, 9, 5, 12);
    final times = PrayerTimes(
      coordinates: Coordinates(31.5204, 74.3587),
      date: date,
      calculationParameters: CalculationMethodParameters.karachi()
        ..madhab = Madhab.hanafi,
      precision: true,
    );

    final schedule = PrayerScheduleCalculator().calculate(times);

    expect(schedule.map((entry) => entry.prayer), [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ]);
    expect(schedule, isNotEmpty);
    expect(schedule.every((entry) => entry.time.isAfter(DateTime(2026, 9, 4))), isTrue);
  });

  test('includes sunrise separately without treating it as a salah', () {
    final date = DateTime(2026, 9, 5, 12);
    final times = PrayerTimes(
      coordinates: Coordinates(31.5204, 74.3587),
      date: date,
      calculationParameters: CalculationMethodParameters.karachi()
        ..madhab = Madhab.hanafi,
      precision: true,
    );

    final sunrise = PrayerScheduleCalculator().sunrise(times);

    expect(sunrise.prayer, Prayer.sunrise);
    expect(sunrise.time, times.sunrise.toLocal());
  });
}
