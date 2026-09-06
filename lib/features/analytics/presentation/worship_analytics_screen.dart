import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/src/core/storage/app_boxes.dart';
import '../services/worship_analytics_service.dart';

class WorshipAnalyticsScreen extends StatefulWidget {
  const WorshipAnalyticsScreen({super.key});

  @override
  State<WorshipAnalyticsScreen> createState() => _WorshipAnalyticsScreenState();
}

class _WorshipAnalyticsScreenState extends State<WorshipAnalyticsScreen> {
  late Future<dynamic> _report;

  @override
  void initState() {
    super.initState();
    _report = _load();
  }

  Future<dynamic> _load() async {
    final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
        ? Hive.box<Map>(AppBoxes.worshipActivity)
        : await Hive.openBox<Map>(AppBoxes.worshipActivity);
    final repository =
        WorshipActivityRepository(HiveWorshipActivityBackend(box));
    return WorshipAnalyticsService(repository).loadWeek();
  }

  void _refresh() => setState(() => _report = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worship Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
        future: _report,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insights_outlined, size: 52),
                    const SizedBox(height: 12),
                    const Text('Worship insights could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _SummaryCard(report: report),
                const SizedBox(height: 16),
                Text(
                  'Last 7 days',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: Column(
                      children: [
                        for (final day in report.days)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _DayRow(day: day),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Insights are a reflection tool, not a measure of religious worth.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final dynamic report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final score = (report.averageScore * 100).round();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Text(
              'Your week at a glance',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('$score% average daily progress'),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: report.averageScore, minHeight: 8),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatChip(label: 'Active days', value: '${report.activeDays}'),
                _StatChip(label: 'Streak', value: '${report.currentStreak}'),
                _StatChip(label: 'Salah', value: '${report.completedSalah}'),
                _StatChip(label: 'Quran pages', value: '${report.quranPages}'),
                _StatChip(label: 'Dhikr', value: '${report.dhikrCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final dynamic day;

  @override
  Widget build(BuildContext context) {
    final date = day.date as DateTime;
    final score = day.score as double;
    final summary = day.summary;
    final label = '${date.day}/${date.month}';
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: score, minHeight: 10),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 54,
          child: Text(
            '${(score * 100).round()}%',
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message:
              '${summary.prayersCompleted}/5 Salah • ${summary.quranPages} Quran pages • ${summary.dhikrCount} Dhikr',
          child: Icon(
            day.hasActivity ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: 20,
          ),
        ),
      ],
    );
  }
}
