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
    '1-1': [
      IslamicCalendarEvent(
        title: 'Islamic New Year',
        description: 'The beginning of a new Hijri year. It is a calendar milestone rather than a prescribed annual worship day.',
        icon: '🌙',
      ),
    ],
    '1-10': [
      IslamicCalendarEvent(
        title: 'Ashura',
        description: 'The tenth day of Muharram. Fasting this day is a well-known Sunnah, with the ninth also encouraged when possible.',
        icon: '🌙',
      ),
    ],
    '3-12': [
      IslamicCalendarEvent(
        title: 'Mawlid an-Nabi',
        description: 'A date commonly used by some Muslims to commemorate the birth of Prophet Muhammad ﷺ; observance is not universal.',
        icon: '✨',
      ),
    ],
    '9-1': [
      IslamicCalendarEvent(
        title: 'Ramadan begins',
        description: 'The first day of Ramadan according to the selected calculated Hijri calendar. Local moon sighting can produce a different observance date.',
        icon: '🌙',
      ),
    ],
    '9-21': [
      IslamicCalendarEvent(
        title: 'Last ten nights begin',
        description: 'The final ten nights of Ramadan begin. They are a special period for increased prayer, Quran recitation, remembrance and seeking Laylat al-Qadr.',
        icon: '✨',
      ),
    ],
    '9-27': [
      IslamicCalendarEvent(
        title: '27th night of Ramadan',
        description: 'A night commonly highlighted for Laylat al-Qadr. The exact night of Laylat al-Qadr is sought among the last ten nights, especially the odd nights.',
        icon: '✨',
      ),
    ],
    '10-1': [
      IslamicCalendarEvent(
        title: 'Eid al-Fitr',
        description: 'The first day of Shawwal and Eid al-Fitr, following the completion of Ramadan.',
        icon: '🎉',
      ),
    ],
    '12-1': [
      IslamicCalendarEvent(
        title: 'First ten days of Dhul Hijjah',
        description: 'The first ten days of Dhul Hijjah are a virtuous season for increased remembrance, good deeds and worship.',
        icon: '🕋',
      ),
    ],
    '12-9': [
      IslamicCalendarEvent(
        title: 'Day of Arafah',
        description: 'The ninth day of Dhul Hijjah. It is a major day of worship during Hajj, and fasting it is recommended for those not performing Hajj.',
        icon: '🕋',
      ),
    ],
    '12-10': [
      IslamicCalendarEvent(
        title: 'Eid al-Adha',
        description: 'The tenth day of Dhul Hijjah and Eid al-Adha, the festival associated with the sacrifice and the Hajj season.',
        icon: '🕋',
      ),
    ],
    '12-11': [
      IslamicCalendarEvent(
        title: 'Days of Tashreeq',
        description: 'The eleventh day of Dhul Hijjah, part of the Days of Tashreeq when pilgrims continue the rites of Hajj and remembrance is emphasized.',
        icon: '🕋',
      ),
    ],
    '12-12': [
      IslamicCalendarEvent(
        title: 'Days of Tashreeq',
        description: 'The twelfth day of Dhul Hijjah, one of the Days of Tashreeq. Remembrance of Allah is emphasized during these days.',
        icon: '🕋',
      ),
    ],
    '12-13': [
      IslamicCalendarEvent(
        title: 'Last Day of Tashreeq',
        description: 'The thirteenth day of Dhul Hijjah and the final Day of Tashreeq, after which the Hajj season rites move beyond these designated days.',
        icon: '🕋',
      ),
    ],
  };
}
