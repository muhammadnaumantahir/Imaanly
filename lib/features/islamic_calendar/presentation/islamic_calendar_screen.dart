import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../domain/islamic_calendar_day.dart';
import '../domain/islamic_calendar_service.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});
  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  final IslamicCalendarService _service = IslamicCalendarService();
  late HijriCalendar _month;
  late DateTime _today;
  IslamicCalendarDay? _selected;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _month = HijriCalendar.fromDate(_today);
    _selectToday();
  }

  void _selectToday() {
    final h = HijriCalendar.fromDate(_today);
    final days = _service.monthDays(h.hYear, h.hMonth);
    for (final day in days) {
      if (_sameDay(day.date, _today)) {
        _selected = day;
        break;
      }
    }
  }

  void _shift(int delta) {
    var year = _month.hYear;
    var month = _month.hMonth + delta;
    if (month < 1) { month = 12; year--; }
    if (month > 12) { month = 1; year++; }
    setState(() {
      _month = HijriCalendar()..hYear = year..hMonth = month..hDay = 1;
      _selected = null;
    });
  }

  void _todayPressed() {
    setState(() {
      _month = HijriCalendar.fromDate(_today);
      _selected = null;
      _selectToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _service.monthDays(_month.hYear, _month.hMonth);
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar'), actions: [IconButton(onPressed: _todayPressed, icon: const Icon(Icons.today_outlined), tooltip: 'Today')]),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          Row(children: [IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)), Expanded(child: Center(child: Text('Hijri ${_month.hMonth}/${_month.hYear}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)))), IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right))]),
          const SizedBox(height: 12),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6), itemCount: days.length, itemBuilder: (context, index) {
            final day = days[index];
            final selected = _selected != null && _sameDay(_selected!.date, day.date);
            return InkWell(onTap: day.isCurrentMonth ? () => setState(() => _selected = day) : null, borderRadius: BorderRadius.circular(10), child: Container(decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primaryContainer : null, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(day.hijriLabel, style: TextStyle(fontWeight: day.events.isNotEmpty || selected ? FontWeight.w900 : FontWeight.w500, color: day.isCurrentMonth ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35))))));
          }),
        ]))),
        const SizedBox(height: 18),
        if (_selected != null) Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_selected!.date.day}/${_selected!.date.month}/${_selected!.date.year}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), if (_selected!.events.isEmpty) const Text('No built-in occasion is listed for this date.') else ..._selected!.events.map((event) => ListTile(contentPadding: EdgeInsets.zero, leading: Text(event.icon, style: const TextStyle(fontSize: 24)), title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(event.description)))]))),
        const SizedBox(height: 18),
        const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Hijri dates can vary by local moon sighting and calendar convention. Use local authorities for official observance dates.'))),
      ]),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
