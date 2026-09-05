import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class IslamicCalendarScreen extends StatelessWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 32),
                  const SizedBox(height: 16),
                  Text('${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Today • ${now.day}/${now.month}/${now.year}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Local calendar'),
              subtitle: const Text('Hijri dates are calculated on-device. Local moon-sighting adjustments can be added later.'),
            ),
          ),
        ],
      ),
    );
  }
}
