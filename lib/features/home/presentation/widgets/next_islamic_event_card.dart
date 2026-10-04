import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../src/theme/app_widgets.dart';

/// Shows the next major Islamic date and how many days remain.
///
/// Dates come from the calculated Hijri calendar, so the actual observance can
/// differ by a day depending on local moon sighting.
class NextIslamicEventCard extends StatelessWidget {
  const NextIslamicEventCard({super.key, required this.now, this.onTap});

  final DateTime now;
  final VoidCallback? onTap;

  static const List<(int, int, String)> _events = [
    (1, 1, 'Islamic New Year'),
    (1, 10, 'Day of Ashura'),
    (9, 1, 'Start of Ramadan'),
    (10, 1, 'Eid al-Fitr'),
    (12, 9, 'Day of Arafah'),
    (12, 10, 'Eid al-Adha'),
  ];

  ({String name, int days, DateTime date})? _next() {
    final today = DateTime(now.year, now.month, now.day);
    final h = HijriCalendar.fromDate(today);
    ({String name, int days, DateTime date})? best;
    for (final year in [h.hYear, h.hYear + 1]) {
      for (final e in _events) {
        DateTime g;
        try {
          g = HijriCalendar().hijriToGregorian(year, e.$1, e.$2);
        } catch (_) {
          continue;
        }
        final date = DateTime(g.year, g.month, g.day);
        final days = date.difference(today).inDays;
        if (days < 0) continue;
        if (best == null || days < best.days) {
          best = (name: e.$3, days: days, date: date);
        }
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final next = _next();
    if (next == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final countLabel = next.days == 0 ? 'Today' : '${next.days}';

    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          const IconBadge(icon: Icons.event_available_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('EEE, d MMM yyyy').format(next.date)} (approx.)',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                countLabel,
                style: TextStyle(
                  fontSize: next.days == 0 ? 18 : 28,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  height: 1.1,
                ),
              ),
              if (next.days != 0)
                Text(
                  next.days == 1 ? 'day' : 'days',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
