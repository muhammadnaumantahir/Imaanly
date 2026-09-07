class IslamicCalendarDay {
  const IslamicCalendarDay({required this.date, required this.hijriLabel, required this.isCurrentMonth, this.events = const []});

  final DateTime date;
  final String hijriLabel;
  final bool isCurrentMonth;
  final List<IslamicCalendarEvent> events;
}

class IslamicCalendarEvent {
  const IslamicCalendarEvent({required this.title, required this.description, required this.icon});

  final String title;
  final String description;
  final String icon;
}
