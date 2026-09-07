import 'package:flutter/material.dart';

import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_activity.dart';
import 'package:imaanly/src/core/storage/app_boxes.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Local-first seven-day worship history derived from persisted activity.
class WorshipHistoryScreen extends StatefulWidget {
  const WorshipHistoryScreen({super.key});

  @override
  State<WorshipHistoryScreen> createState() => _WorshipHistoryScreenState();
}

class _WorshipHistoryScreenState extends State<WorshipHistoryScreen> {
  late Future<List<_DaySummary>> _history;

  @override
  void initState() {
    super.initState();
    _history = _load();
  }

  Future<List<_DaySummary>> _load() async {
    final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
        ? Hive.box<Map>(AppBoxes.worshipActivity)
        : await Hive.openBox<Map>(AppBoxes.worshipActivity);
    final activities = await WorshipActivityRepository(
      HiveWorshipActivityBackend(box),
    ).getAll();
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      final key = WorshipActivity.dayKey(date);
      final day = activities.where((a) => a.dateKey == key);
      final salah = day.where((a) => a.type == WorshipActivityType.salah).length;
      final quran = day
          .where((a) => a.type == WorshipActivityType.quran)
          .fold<int>(0, (sum, a) => sum + a.amount);
      final dhikr = day
          .where((a) => a.type == WorshipActivityType.dhikr)
          .fold<int>(0, (sum, a) => sum + a.amount);
      return _DaySummary(date: date, salah: salah, quranPages: quran, dhikr: dhikr);
    });
  }

  void _refresh() => setState(() => _history = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worship History'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<_DaySummary>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Unable to load worship history.'));
          }
          final days = snapshot.data ?? const <_DaySummary>[];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final day = days[index];
              final total = day.salah + day.quranPages + day.dhikr;
              final label = '${_weekday(day.date)} • ${day.date.day}/${day.date.month}';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
                        Text(total > 0 ? 'Active' : 'No activity', style: Theme.of(context).textTheme.bodySmall),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: _Stat(icon: Icons.mosque_outlined, label: 'Salah', value: '${day.salah}/5')),
                        Expanded(child: _Stat(icon: Icons.menu_book_outlined, label: 'Quran', value: '${day.quranPages} pages')),
                        Expanded(child: _Stat(icon: Icons.favorite_outline, label: 'Dhikr', value: '${day.dhikr}')),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _weekday(DateTime date) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}

class _DaySummary {
  const _DaySummary({required this.date, required this.salah, required this.quranPages, required this.dhikr});
  final DateTime date;
  final int salah;
  final int quranPages;
  final int dhikr;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 20),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
