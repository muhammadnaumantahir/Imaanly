import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../src/theme/app_widgets.dart';

/// Suhoor / Iftar countdown, shown on the home screen during Ramadan.
class RamadanCard extends StatelessWidget {
  const RamadanCard({
    super.key,
    required this.now,
    required this.fajr,
    required this.maghrib,
    required this.day,
  });

  final DateTime now;
  final DateTime? fajr;
  final DateTime? maghrib;
  final int day;

  String _hms(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (fajr == null || maghrib == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final f = fajr!.toLocal();
    final m = maghrib!.toLocal();
    final clock = DateFormat('h:mm a');

    late final String label;
    late final String detail;
    String? countdown;
    if (now.isBefore(f)) {
      label = 'Suhoor ends in';
      detail = 'Fajr at ${clock.format(f)}';
      countdown = _hms(f.difference(now));
    } else if (now.isBefore(m)) {
      label = 'Iftar in';
      detail = 'Maghrib at ${clock.format(m)}';
      countdown = _hms(m.difference(now));
    } else {
      label = 'Iftar began at ${clock.format(m)}';
      detail = 'May Allah accept your fast';
    }

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const IconBadge(icon: Icons.nights_stay_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ramadan \u2022 Day $day',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: cs.primary),
                ),
                const SizedBox(height: 3),
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
              ],
            ),
          ),
          if (countdown != null)
            Text(
              countdown,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
