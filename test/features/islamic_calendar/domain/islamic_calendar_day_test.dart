import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/islamic_calendar/domain/islamic_calendar_day.dart';

void main() {
  test('keeps civil date and calculated Hijri label together', () {
    final date = DateTime(2026, 9, 6);
    final day = IslamicCalendarDay(date: date, hijriLabel: 'Rabi al-Awwal 1448');
    expect(day.date, date);
    expect(day.hijriLabel, 'Rabi al-Awwal 1448');
  });
}
