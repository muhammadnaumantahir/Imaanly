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
  static const _weekdays = <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _months = <String>[
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Shaaban',
    'Ramadan',
    'Shawwal',
    'Dhul Qadah',
    'Dhul Hijjah',
  ];

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
    if (month < 1) {
      month = 12;
      year--;
    } else if (month > 12) {
      month = 1;
      year++;
    }
    setState(() {
      _month = HijriCalendar()..hYear = year..hMonth = month..hDay = 1;
      _selected = null;
    });
  }

  void _todayPressed() {
    setState(() {
      _today = DateTime.now();
      _month = HijriCalendar.fromDate(_today);
      _selected = null;
      _selectToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final days = _service.monthDays(_month.hYear, _month.hMonth);
    final monthName = _months[_month.hMonth - 1];
    final currentMonthDays = days.where((day) => day.isCurrentMonth).toList();
    final firstCurrentDay = currentMonthDays.isEmpty ? days.first : currentMonthDays.first;
    final lastCurrentDay = currentMonthDays.isEmpty ? days.last : currentMonthDays.last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calendar'),
        actions: [
          TextButton.icon(
            onPressed: _todayPressed,
            icon: const Icon(Icons.today_outlined),
            label: const Text('Today'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous month',
                        onPressed: () => _shift(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$monthName ${_month.hYear}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${firstCurrentDay.date.day} ${_gregorianMonth(firstCurrentDay.date.month)} – ${lastCurrentDay.date.day} ${_gregorianMonth(lastCurrentDay.date.month)} ${lastCurrentDay.date.year}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next month',
                        onPressed: () => _shift(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _weekdays
                        .map(
                          (weekday) => Expanded(
                            child: Center(
                              child: Text(
                                weekday,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final selected = _selected != null && _sameDay(_selected!.date, day.date);
                      final today = _sameDay(day.date, _today);
                      final hasEvents = day.events.isNotEmpty;

                      return InkWell(
                        onTap: day.isCurrentMonth ? () => setState(() => _selected = day) : null,
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color: selected ? scheme.primaryContainer : today ? scheme.secondaryContainer.withValues(alpha: 0.55) : null,
                            borderRadius: BorderRadius.circular(12),
                            border: today ? Border.all(color: scheme.primary, width: 1.5) : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                day.hijriLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: selected || today || hasEvents ? FontWeight.w900 : FontWeight.w600,
                                  color: day.isCurrentMonth ? null : scheme.onSurface.withValues(alpha: 0.32),
                                ),
                              ),
                              if (hasEvents)
                                Positioned(
                                  bottom: 5,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selected != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatGregorianDate(_selected!.date),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_selected!.hijriLabel} • ${_selected!.date.weekday == 5 ? 'Jumu\'ah' : _weekdays[_selected!.date.weekday % 7]}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    if (_selected!.events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'No built-in occasion is listed for this date.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ..._selected!.events.map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Text(event.icon, style: const TextStyle(fontSize: 20)),
                            ),
                            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(event.description),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hijri dates can vary by local moon sighting and calendar convention. Use local authorities for official observance dates.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _gregorianMonth(int month) => const <String>[
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];

  static String _formatGregorianDate(DateTime date) =>
      '${date.day} ${_gregorianMonth(date.month)} ${date.year}';

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
