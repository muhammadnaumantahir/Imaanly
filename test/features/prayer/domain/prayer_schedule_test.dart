import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/prayer/domain/prayer_schedule.dart';
import 'package:imaanly/src/screen/prayer_time/models/prayer_enum.dart';

void main() {
  test('returns the five daily prayers in worship order', () {
    final coordinates = adhan.Coordinates(31.5204, 74.3587);
    final date = DateTime(2026, 9, 5);
    final parameters = adhan.CalculationMethodParameters.karachi()
      ..madhab = adhan.Madhab.hanafi;
    final prayerTimes = adhan.PrayerTimes(coordinates: coordinates, date: date, calculationParameters: parameters);
    final entries = const PrayerScheduleCalculator().calculate(prayerTimes);
    expect(entries.map((entry) => entry.prayer), [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha]);
  });

  test('exposes sunrise separately from the five daily prayers', () {
    final coordinates = adhan.Coordinates(31.5204, 74.3587);
    final date = DateTime(2026, 9, 5);
    final parameters = adhan.CalculationMethodParameters.karachi()..madhab = adhan.Madhab.hanafi;
    final prayerTimes = adhan.PrayerTimes(coordinates: coordinates, date: date, calculationParameters: parameters);
    final sunrise = const PrayerScheduleCalculator().sunrise(prayerTimes);
    expect(sunrise.prayer, Prayer.sunrise);
    expect(sunrise.time, prayerTimes.sunrise.toLocal());
  });

  test('identifies the current prayer from the canonical daily schedule', () {
    final entries = _sampleSchedule();
    final current = const PrayerScheduleCalculator().current(entries, DateTime(2026, 9, 5, 13));
    expect(current?.prayer, Prayer.dhuhr);
  });

  test('identifies the next prayer from the canonical daily schedule', () {
    final entries = _sampleSchedule();
    final next = const PrayerScheduleCalculator().next(entries, DateTime(2026, 9, 5, 13));
    expect(next?.prayer, Prayer.asr);
  });

  test('returns no current prayer before Fajr', () {
    final entries = _sampleSchedule();
    final current = const PrayerScheduleCalculator().current(entries, DateTime(2026, 9, 5, 4));
    expect(current, isNull);
  });

  test('returns no next prayer after Isha', () {
    final entries = _sampleSchedule();
    final next = const PrayerScheduleCalculator().next(entries, DateTime(2026, 9, 5, 21, 30));
    expect(next, isNull);
  });

  test('uses the following day Fajr after Isha', () {
    final coordinates = adhan.Coordinates(31.5204, 74.3587);
    final date = DateTime(2026, 9, 5);
    final parameters = adhan.CalculationMethodParameters.karachi()..madhab = adhan.Madhab.hanafi;
    final today = adhan.PrayerTimes(coordinates: coordinates, date: date, calculationParameters: parameters);
    final tomorrow = adhan.PrayerTimes(coordinates: coordinates, date: date.add(const Duration(days: 1)), calculationParameters: parameters);
    final nextFajr = const PrayerScheduleCalculator().nextDayFajr(tomorrow);
    expect(nextFajr.prayer, Prayer.fajr);
    expect(nextFajr.time, tomorrow.fajr.toLocal());
    expect(nextFajr.time.day, 6);
    expect(today.isha.isBefore(nextFajr.time), isTrue);
  });
}

List<PrayerScheduleEntry> _sampleSchedule() => [
      PrayerScheduleEntry(prayer: Prayer.fajr, time: DateTime(2026, 9, 5, 5)),
      PrayerScheduleEntry(prayer: Prayer.dhuhr, time: DateTime(2026, 9, 5, 12)),
      PrayerScheduleEntry(prayer: Prayer.asr, time: DateTime(2026, 9, 5, 16)),
      PrayerScheduleEntry(prayer: Prayer.maghrib, time: DateTime(2026, 9, 5, 18, 30)),
      PrayerScheduleEntry(prayer: Prayer.isha, time: DateTime(2026, 9, 5, 20)),
    ];
