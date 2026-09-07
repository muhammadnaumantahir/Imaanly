import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/prayer/domain/prayer_schedule.dart';
import 'package:imaanly/src/screen/prayer_time/models/prayer_enum.dart';

void main() {
  test('builds the five daily prayers in chronological order', () {
    final date = DateTime(2026, 9, 5, 12);
    final times = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(31.5204, 74.3587),
      date: date,
      calculationParameters:
          adhan.CalculationMethodParameters.karachi()..madhab = adhan.Madhab.hanafi,
      precision: true,
    );
    final schedule = PrayerScheduleCalculator().calculate(times);
    expect(schedule.map((entry) => entry.prayer).toList(), [
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
    final times = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(31.5204, 74.3587),
      date: date,
      calculationParameters:
          adhan.CalculationMethodParameters.karachi()..madhab = adhan.Madhab.hanafi,
      precision: true,
    );
    final sunrise = PrayerScheduleCalculator().sunrise(times);
    expect(sunrise.prayer, Prayer.sunrise);
    expect(sunrise.time, times.sunrise.toLocal());
  });
}
