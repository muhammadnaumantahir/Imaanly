import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';
import 'package:imaanly/features/worship_dashboard/domain/worship_dashboard_summary.dart';
import 'package:imaanly/src/core/reading_stats/reading_stats_cubit.dart';
import 'package:imaanly/src/core/storage/app_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Daily worship overview backed by the unified local worship activity store.
class WorshipDashboardScreen extends StatefulWidget {
  const WorshipDashboardScreen({super.key});

  @override
  State<WorshipDashboardScreen> createState() => _WorshipDashboardScreenState();
}

class _WorshipDashboardScreenState extends State<WorshipDashboardScreen> {
  Future<WorshipDailySummary>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<WorshipDailySummary> _loadSummary() async {
    final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
        ? Hive.box<Map>(AppBoxes.worshipActivity)
        : await Hive.openBox<Map>(AppBoxes.worshipActivity);
    final repository = WorshipActivityRepository(HiveWorshipActivityBackend(box));
    return repository.getDailySummary(DateTime.now());
  }

  void _refresh() {
    setState(() => _summaryFuture = _loadSummary());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingStatsCubit, ReadingStatsState>(
      builder: (context, reading) {
        return FutureBuilder<WorshipDailySummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            final activity = snapshot.data;
            final summary = WorshipDashboardSummary(
              prayersCompleted: activity?.prayersCompleted ?? 0,
              prayersTotal: activity?.prayersTotal ?? 5,
              quranPages: reading.pagesToday,
              dhikrCompleted: activity?.dhikrCount ?? 0,
              dhikrGoal: activity?.dhikrGoal ?? 33,
              readingStreak: reading.streak,
            );

            return Scaffold(
              appBar: AppBar(
                title: const Text('Worship Today'),
                centerTitle: true,
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: snapshot.connectionState == ConnectionState.waiting
                        ? null
                        : _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _HeroCard(summary: summary),
                    const SizedBox(height: 16),
                    _ProgressCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Quran',
                      value: '${summary.quranPages} pages today',
                      progress: (summary.quranPages / 5).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 12),
                    _ProgressCard(
                      icon: Icons.favorite_rounded,
                      title: 'Dhikr',
                      value: '${summary.dhikrCompleted} / ${summary.dhikrGoal}',
                      progress: summary.dhikrProgress,
                    ),
                    const SizedBox(height: 12),
                    _ProgressCard(
                      icon: Icons.mosque_rounded,
                      title: 'Salah',
                      value: '${summary.prayersCompleted} / ${summary.prayersTotal} completed',
                      progress: summary.prayerProgress,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_fire_department_rounded),
                        title: const Text('Reading streak'),
                        subtitle: Text(
                          '${summary.readingStreak} consecutive day${summary.readingStreak == 1 ? '' : 's'}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (snapshot.hasError)
                      Text(
                        'Worship activity could not be loaded. Your existing Quran progress is still shown.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      )
                    else
                      Text(
                        'Your worship activity stays on this device. Each feature contributes to one daily view as tracking is enabled.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});
  final WorshipDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = summary.prayersCompleted > 0 ||
        summary.quranPages > 0 ||
        summary.dhikrCompleted > 0;
    final progress = ((summary.prayerProgress +
                (summary.quranPages / 5).clamp(0.0, 1.0) +
                summary.dhikrProgress) /
            3)
        .clamp(0.0, 1.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completed ? 'Keep going' : 'Begin gently',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A simple view of today\'s worship habits.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress),
                  const Icon(Icons.auto_awesome_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }
}
