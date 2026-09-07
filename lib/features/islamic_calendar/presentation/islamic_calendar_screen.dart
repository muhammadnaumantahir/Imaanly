import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:imaanly/features/islamic_calendar/domain/islamic_calendar_day.dart';
import 'package:imaanly/features/islamic_calendar/domain/islamic_calendar_service.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});
  @override State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  final _service = IslamicCalendarService();
  late DateTime _selectedMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    final h = HijriCalendar.fromDate(_today);
    _selectedMonth = DateTime(h.hYear, h.hMonth, 1);
  }

  void _shiftMonth(int delta) => setState(() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    _selectedMonth = next;
  });

  void _goToday() {
    final h = HijriCalendar.fromDate(_today);
    setState(() => _selectedMonth = DateTime(h.hYear, h.hMonth, 1));
  }

  @override
  Widget build(BuildContext context) {
    final h = HijriCalendar()..hYear = _selectedMonth.year..hMonth = _selectedMonth.month..hDay = 1;
    final days = _service.monthDays(h.hYear, h.hMonth);
    final todayH = _service.hijriFor(_today);
    final selectedEvents = _service.eventsForHijri(h.hYear, h.hMonth, 1);
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar'), centerTitle: true, actions: [IconButton(onPressed: _goToday, tooltip: 'Today', icon: const Icon(Icons.today_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        _TodayCard(today: _today, hijri: todayH),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 16), child: Column(children: [
          Row(children: [IconButton(onPressed: () => _shiftMonth(-1), icon: const Icon(Icons.chevron_left_rounded)), Expanded(child: Column(children: [Text(h.getLongMonthName(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), Text('${h.hYear} AH', style: Theme.of(context).textTheme.bodySmall)])), IconButton(onPressed: () => _shiftMonth(1), icon: const Icon(Icons.chevron_right_rounded))]),
          const SizedBox(height: 8),
          const Row(children: [Expanded(child: Center(child: Text('Sun'))), Expanded(child: Center(child: Text('Mon'))), Expanded(child: Center(child: Text('Tue'))), Expanded(child: Center(child: Text('Wed'))), Expanded(child: Center(child: Text('Thu'))), Expanded(child: Center(child: Text('Fri'))), Expanded(child: Center(child: Text('Sat')))]),
          const SizedBox(height: 8),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: days.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 4), itemBuilder: (context, index) => _DayCell(day: days[index], isToday: _sameDay(days[index].date, _today))),
        ]))),
        const SizedBox(height: 16),
        if (selectedEvents.isNotEmpty) ...[
          Text('Featured dates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...selectedEvents.map((event) => _EventCard(event: event)),
        ],
        const SizedBox(height: 8),
        Card(child: ListTile(leading: const Icon(Icons.info_outline_rounded), title: const Text('Calculated Hijri calendar'), subtitle: const Text('Dates are calculated on-device. Local moon-sighting adjustments may shift an occasion by a day.'))),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today, required this.hijri});
  final DateTime today;
  final HijriCalendar hijri;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; return Card(clipBehavior: Clip.antiAlias, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primaryContainer, scheme.surfaceContainerHighest])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.nightlight_round, size: 30), const SizedBox(height: 14), Text('${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} AH', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text('${today.day}/${today.month}/${today.year}', style: Theme.of(context).textTheme.bodyMedium)]))); }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday});
  final IslamicCalendarDay day; final bool isToday;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; return Container(decoration: BoxDecoration(color: isToday ? scheme.primaryContainer : null, borderRadius: BorderRadius.circular(10), border: day.events.isNotEmpty ? Border.all(color: scheme.primary.withValues(alpha: .45)) : null), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${day.date.day}', style: TextStyle(color: day.isCurrentMonth ? null : scheme.onSurfaceVariant.withValues(alpha: .45), fontWeight: isToday ? FontWeight.w900 : FontWeight.w500)), Text(day.hijriLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: day.isCurrentMonth ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: .45)))])); }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event}); final IslamicCalendarEvent event;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: Text(event.icon, style: const TextStyle(fontSize: 24)), title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(event.description)));
}
