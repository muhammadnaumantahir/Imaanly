import 'package:hijri/hijri_calendar.dart';
import 'package:imaanly/features/islamic_calendar/domain/islamic_calendar_day.dart';

class IslamicCalendarService {
  HijriCalendar hijriFor(DateTime date) => HijriCalendar.fromDate(date);

  List<IslamicCalendarEvent> eventsForHijri(int year, int month, int day) {
    final key = '$month-$day';
    return _events[key] ?? const [];
  }

  List<IslamicCalendarDay> monthDays(int year, int month) {
    final firstHijri = HijriCalendar()..hYear = year..hMonth = month..hDay = 1;
    final firstGregorian = firstHijri.hijriToGregorian(year, month, 1);
    final start = DateTime(firstGregorian.year, firstGregorian.month, firstGregorian.day);
    final daysInMonth = month == 12 ? 30 : _monthLength(year, month);
    final firstWeekday = start.weekday % 7;
    final total = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    return List.generate(total, (index) {
      final date = start.add(Duration(days: index - firstWeekday));
      final h = HijriCalendar.fromDate(date);
      return IslamicCalendarDay(
        date: date,
        hijriLabel: '${h.hDay}',
        isCurrentMonth: h.hYear == year && h.hMonth == month,
        events: eventsForHijri(h.hYear, h.hMonth, h.hDay),
      );
    });
  }

  int _monthLength(int year, int month) {
    final first = HijriCalendar()..hYear = year..hMonth = month..hDay = 1;
    final next = month == 12
        ? (HijriCalendar()..hYear = year + 1..hMonth = 1..hDay = 1)
        : (HijriCalendar()..hYear = year..hMonth = month + 1..hDay = 1);
    final a = first.hijriToGregorian(year, month, 1);
    final b = next.hijriToGregorian(next.hYear, next.hMonth, 1);
    return DateTime(b.year, b.month, b.day).difference(DateTime(a.year, a.month, a.day)).inDays;
  }

  static const _events = <String, List<IslamicCalendarEvent>>{
    '1-1': [IslamicCalendarEvent(title: 'Islamic New Year', description: 'The beginning of a new Hijri year.', icon: '🌙')],
    '1-10': [IslamicCalendarEvent(title: 'Ashura', description: 'The tenth day of Muharram.', icon: '🌙')],
    '3-12': [IslamicCalendarEvent(title: 'Mawlid an-Nabi', description: 'A commonly observed date commemorating the birth of Prophet Muhammad ﷺ.', icon: '✨')],
    '9-1': [IslamicCalendarEvent(title: 'Ramadan begins', description: 'The first day of Ramadan according to the calculated Hijri date.', icon: '🌙')],
    '9-27': [IslamicCalendarEvent(title: 'Laylat al-Qadr', description: 'The 27th night of Ramadan is traditionally observed by many Muslims.', icon: '✨')],
    '10-1': [IslamicCalendarEvent(title: 'Eid al-Fitr', description: 'The first day of Shawwal and Eid al-Fitr.', icon: '🎉')],
    '12-9': [IslamicCalendarEvent(title: 'Day of Arafah', description: 'The ninth day of Dhul Hijjah.', icon: '🕋')],
    '12-10': [IslamicCalendarEvent(title: 'Eid al-Adha', description: 'The tenth day of Dhul Hijjah and Eid al-Adha.', icon: '🕋')],
  };
}
