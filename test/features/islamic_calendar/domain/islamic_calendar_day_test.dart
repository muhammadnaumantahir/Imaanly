import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/islamic_calendar/domain/islamic_calendar_day.dart';

void main() {
  test('keeps civil date and calculated Hijri label together', () {
    final date = DateTime(2026, 9, 6);
    final day = IslamicCalendarDay(
      date: date,
      hijriLabel: 'Rabi al-Awwal 1448',
      isCurrentMonth: true,
    );
    expect(day.date, date);
    expect(day.hijriLabel, 'Rabi al-Awwal 1448');
    expect(day.isCurrentMonth, isTrue);
  });

  test('defaults to an empty event list', () {
    final day = IslamicCalendarDay(
      date: DateTime(2026, 9, 6),
      hijriLabel: 'Rabi al-Awwal 1448',
      isCurrentMonth: true,
    );

    expect(day.events, isEmpty);
  });

  test('preserves events attached to a calendar day', () {
    const event = IslamicCalendarEvent(
      title: 'Prophetic Birthday',
      description: 'A calendar event',
      icon: 'moon',
    );
    final day = IslamicCalendarDay(
      date: DateTime(2026, 9, 6),
      hijriLabel: 'Rabi al-Awwal 1448',
      isCurrentMonth: true,
      events: [event],
    );

    expect(day.events, hasLength(1));
    expect(day.events.single.title, 'Prophetic Birthday');
    expect(day.events.single.description, 'A calendar event');
    expect(day.events.single.icon, 'moon');
  });
}
