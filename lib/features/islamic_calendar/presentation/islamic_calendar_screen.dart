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
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    final h = HijriCalendar.fromDate(_today);
    _selectedMonth = DateTime(h.hYear, h.hMonth, 1);
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

  void _shiftMonth(int delta) => setState(() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    _selectedMonth = next;
    _selectedDate = null;
  });

  void _goToday() {
    final h = HijriCalendar.fromDate(_today);
    setState(() {
      _selectedMonth = DateTime(h.hYear, h.hMonth, 1);
      _selectedDate = DateTime(_today.year, _today.month, _today.day);
    });
  }

  void _selectDay(IslamicCalendarDay day) {
    if (!day.isCurrentMonth) return;
    setState(() => _selectedDate = DateTime(day.date.year, day.date.month, day.date.day));
  }

  @override
  Widget build(BuildContext context) {
    final h = HijriCalendar()..hYear = _selectedMonth.year..hMonth = _selectedMonth.month..hDay = 1;
    final days = _service.monthDays(h.hYear, h.hMonth);
    final todayH = _service.hijriFor(_today);
    final selected = _selectedDate;
    final selectedHijri = selected == null ? null : _service.hijriFor(selected);
    final selectedEvents = selectedHijri == null
        ? const <IslamicCalendarEvent>[]
        : _service.eventsForHijri(selectedHijri.hYear, selectedHijri.hMonth, selectedHijri.hDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calendar'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _goToday, tooltip: 'Today', icon: const Icon(Icons.today_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _TodayCard(today: _today, hijri: todayH),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => _shiftMonth(-1), icon: const Icon(Icons.chevron_left_rounded)),
                      Expanded(
                        child: Column(
                          children: [
                            Text(h.getLongMonthName(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                            Text('${h.hYear} AH', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => _shiftMonth(1), icon: const Icon(Icons.chevron_right_rounded)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Expanded(child: Center(child: Text('Sun'))), Expanded(child: Center(child: Text('Mon'))), Expanded(child: Center(child: Text('Tue'))),
                      Expanded(child: Center(child: Text('Wed'))), Expanded(child: Center(child: Text('Thu'))), Expanded(child: Center(child: Text('Fri'))), Expanded(child: Center(child: Text('Sat'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 4),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      return _DayCell(
                        day: day,
                        isToday: _sameDay(day.date, _today),
                        isSelected: selected != null && _sameDay(day.date, selected),
                        onTap: () => _selectDay(day),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selected != null) ...[
            Text('Selected date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _SelectedDateCard(date: selected, hijri: selectedHijri!, events: selectedEvents),
            const SizedBox(height: 16),
          ],
          if (selectedEvents.isNotEmpty) ...[
            Text('Event details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...selectedEvents.map((event) => _EventCard(event: event)),
          ] else if (selected != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('No featured occasion'),
                subtitle: const Text('This date has no built-in Islamic calendar event.'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Card(child: ListTile(leading: const Icon(Icons.info_outline_rounded), title: const Text('Calculated Hijri calendar'), subtitle: const Text('Dates are calculated on-device. Local moon-sighting adjustments may shift an occasion by a day.'))),
        ],
      ),
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

class _SelectedDateCard extends StatelessWidget {
  const _SelectedDateCard({required this.date, required this.hijri, required this.events});
  final DateTime date;
  final HijriCalendar hijri;
  final List<IslamicCalendarEvent> events;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.calendar_month_rounded, size: 30), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} AH', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${date.day}/${date.month}/${date.year} Gregorian'), if (events.isNotEmpty) Text('${events.length} featured event${events.length == 1 ? '' : 's'}')]))]));
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, required this.isSelected, required this.onTap});
  final IslamicCalendarDay day; final bool isToday; final bool isSelected; final VoidCallback onTap;
  @override Widget build(BuildContext context) { final scheme = Theme.of(context).colorScheme; return InkWell(onTap: day.isCurrentMonth ? onTap : null, borderRadius: BorderRadius.circular(10), child: Container(decoration: BoxDecoration(color: isSelected ? scheme.primary : (isToday ? scheme.primaryContainer : null), borderRadius: BorderRadius.circular(10), border: day.events.isNotEmpty ? Border.all(color: scheme.primary.withValues(alpha: .45)) : null), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${day.date.day}', style: TextStyle(color: isSelected ? scheme.onPrimary : (day.isCurrentMonth ? null : scheme.onSurfaceVariant.withValues(alpha: .45)), fontWeight: isToday || isSelected ? FontWeight.w900 : FontWeight.w500)), Text(day.hijriLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isSelected ? scheme.onPrimary : (day.isCurrentMonth ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: .45)))])))); }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event}); final IslamicCalendarEvent event;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: Text(event.icon, style: const TextStyle(fontSize: 24)), title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(event.description)));
}
