import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/theme/app_widgets.dart';
import '../data/prayer_tracker_store.dart';

/// Tracks the five daily prayers, with streaks and a 14-day history.
/// Tap a past day in the history to fill in prayers you forgot to tick.
class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  final PrayerTrackerStore _store = PrayerTrackerStore.instance;
  late DateTime _selected;

  static const List<IconData> _icons = [
    Icons.wb_twilight_rounded,
    Icons.wb_sunny_rounded,
    Icons.wb_cloudy_rounded,
    Icons.nights_stay_outlined,
    Icons.nightlight_round,
  ];
  static const List<String> _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selected = PrayerTrackerStore.dateOnly(DateTime.now());
    _store.load();
  }

  bool get _isToday => _selected == PrayerTrackerStore.dateOnly(DateTime.now());

  String _dayLabel(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = PrayerTrackerStore.dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer tracker')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final done = _store.doneCount(_selected);
            final streak = _store.currentStreak(today);
            final best = _store.bestStreak();
            final history = _store.lastDays(today, 14);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                HeroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 96,
                                  height: 96,
                                  child: CircularProgressIndicator(
                                    value: done / 5,
                                    strokeWidth: 9,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                                  ),
                                ),
                                Text(
                                  '$done/5',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isToday ? 'Today' : _dayLabel(_selected),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  done == 5
                                      ? 'All five prayers completed. Alhamdulillah!'
                                      : done == 0
                                          ? 'Tick each prayer as you complete it.'
                                          : '${5 - done} to go. Keep it up!',
                                  style: const TextStyle(color: Colors.white70, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _HeroStat(label: 'Current streak', value: '$streak ${streak == 1 ? 'day' : 'days'}')),
                          const SizedBox(width: 10),
                          Expanded(child: _HeroStat(label: 'Best streak', value: '$best ${best == 1 ? 'day' : 'days'}')),
                          const SizedBox(width: 10),
                          Expanded(child: _HeroStat(label: 'Total prayed', value: '${_store.totalPrayed()}')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isToday ? "Today's prayers" : 'Prayers on ${_dayLabel(_selected)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (!_isToday)
                      TextButton(
                        onPressed: () => setState(() => _selected = today),
                        child: const Text('Back to today'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PrayerRow(
                      name: PrayerTrackerStore.prayerNames[i],
                      icon: _icons[i],
                      done: _store.isDone(_selected, i),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _store.toggle(_selected, i);
                      },
                    ),
                  ),
                const SizedBox(height: 14),
                const Text('Last 14 days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Tap a day to review or fill in missed prayers.',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 14),
                SoftCard(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 14,
                    spacing: 6,
                    children: [
                      for (var i = 0; i < history.length; i++)
                        _DayDot(
                          letter: _weekdayLetters[PrayerTrackerStore.addDays(today, -(history.length - 1 - i)).weekday - 1],
                          count: history[i],
                          selected: PrayerTrackerStore.addDays(today, -(history.length - 1 - i)) == _selected,
                          onTap: () => setState(
                            () => _selected = PrayerTrackerStore.addDays(today, -(history.length - 1 - i)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.name, required this.icon, required this.done, required this.onTap});

  final String name;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconBadge(icon: icon, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: done ? cs.onSurfaceVariant : cs.onSurface,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: cs.onSurfaceVariant,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? cs.primary : Colors.transparent,
              border: Border.all(color: done ? cs.primary : cs.outline, width: 1.8),
            ),
            child: done ? Icon(Icons.check_rounded, size: 19, color: cs.onPrimary) : null,
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.letter, required this.count, required this.selected, required this.onTap});

  final String letter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fill = count == 0 ? Colors.transparent : cs.primary.withValues(alpha: 0.2 + 0.16 * count);
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 38,
        child: Column(
          children: [
            Text(letter, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: Border.all(
                  color: selected ? AppColors.goldDeep : cs.outlineVariant,
                  width: selected ? 2.4 : 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: count == 5
                  ? Icon(Icons.check_rounded, size: 18, color: cs.onPrimary)
                  : (count == 0
                      ? null
                      : Text(
                          '$count',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cs.onSurface),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
