import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/home/domain/next_prayer.dart';

void main() {
  final calculator = const NextPrayerCalculator();
  final prayerTimes = PrayerTimes(
    coordinates: const Coordinates(31.5204, 74.3587),
    date: DateTime(2026, 9, 5),
    calculationParameters: CalculationMethodParameters.karachi()
      ..madhab = Madhab.hanafi,
    precision: true,
  );

  test('selects the first prayer after the supplied time', () {
    final now = prayerTimes.fajr.toLocal().subtract(const Duration(minutes: 1));

    final result = calculator.calculate(prayerTimes, now);

    expect(result, isNotNull);
    expect(result!.prayer, Prayer.fajr);
    expect(result.time, prayerTimes.fajr.toLocal());
    expect(result.remaining, const Duration(minutes: 1));
  });

  test('rolls over to the next day Fajr after Isha', () {
    final now = prayerTimes.isha.toLocal().add(const Duration(minutes: 1));

    final result = calculator.calculate(prayerTimes, now);

    expect(result, isNotNull);
    expect(result!.prayer, Prayer.fajr);
    expect(result.time, prayerTimes.fajrAfter.toLocal());
    expect(result.remaining.isNegative, isFalse);
  });
}
