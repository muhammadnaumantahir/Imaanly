import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:imaanly/features/islamic_calendar/domain/islamic_calendar_service.dart';

void main() {
  group('IslamicCalendarService', () {
    final service = IslamicCalendarService();

    test('converts a Gregorian date to a stable Hijri date', () {
      final result = service.hijriFor(DateTime(2024, 4, 10));
      expect(result.hYear, 1445);
      expect(result.hMonth, 10);
      expect(result.hDay, 1);
    });

    test('returns known Islamic events for a Hijri date', () {
      final events = service.eventsForHijri(1445, 10, 1);
      expect(events.map((event) => event.title), contains('Eid al-Fitr'));
    });

    test('returns expanded Dhul Hijjah worship events', () {
      expect(service.eventsForHijri(1445, 12, 1).map((e) => e.title), contains('First ten days of Dhul Hijjah'));
      expect(service.eventsForHijri(1445, 12, 9).map((e) => e.title), contains('Day of Arafah'));
      expect(service.eventsForHijri(1445, 12, 10).map((e) => e.title), contains('Eid al-Adha'));
      expect(service.eventsForHijri(1445, 12, 11).map((e) => e.title), contains('Days of Tashreeq'));
      expect(service.eventsForHijri(1445, 12, 13).map((e) => e.title), contains('Last Day of Tashreeq'));
    });

    test('returns a complete month grid with adjacent days', () {
      final days = service.monthDays(1445, 10);
      expect(days.length, greaterThanOrEqualTo(35));
      expect(days.any((day) => day.isCurrentMonth), isTrue);
    });

    test('uses the actual length of Dhul Hijjah instead of assuming 30 days', () {
      const year = 1445;
      const month = 12;
      final first = HijriCalendar()..hYear = year..hMonth = month..hDay = 1;
      final next = HijriCalendar()..hYear = year + 1..hMonth = 1..hDay = 1;
      final firstGregorian = first.hijriToGregorian(year, month, 1);
      final nextGregorian = next.hijriToGregorian(year + 1, 1, 1);
      final expectedLength = DateTime(nextGregorian.year, nextGregorian.month, nextGregorian.day)
          .difference(DateTime(firstGregorian.year, firstGregorian.month, firstGregorian.day))
          .inDays;

      final actualLength = service.monthDays(year, month)
          .where((day) => day.isCurrentMonth)
          .length;

      expect(actualLength, expectedLength);
    });
  });
}
