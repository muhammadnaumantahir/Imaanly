import 'package:imaanly/features/fasting/data/fasting_repository.dart';
import 'package:imaanly/features/fasting/domain/fasting_entry.dart';
import 'package:imaanly/features/goals/data/daily_goals_repository.dart';
import 'package:imaanly/features/goals/domain/daily_goals.dart';
import 'package:imaanly/features/goals/presentation/daily_goals_screen.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:imaanly/features/personalization/presentation/personalization_cubit.dart';
import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_analytics.dart';
import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';
import 'package:imaanly/features/worship_dashboard/domain/worship_dashboard_summary.dart';
import 'package:imaanly/features/worship_dashboard/presentation/worship_history_screen.dart';
import 'package:imaanly/src/core/di/service_locator.dart';
import 'package:imaanly/src/core/reading_stats/reading_stats_cubit.dart';
import 'package:imaanly/src/core/storage/app_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorshipDashboardScreen extends StatefulWidget {
  const WorshipDashboardScreen({super.key});
  @override State<WorshipDashboardScreen> createState() => _WorshipDashboardScreenState();
}

class _WorshipDashboardScreenState extends State<WorshipDashboardScreen> {
  Future<_DashboardData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
        ? Hive.box<Map>(AppBoxes.worshipActivity)
        : await Hive.openBox<Map>(AppBoxes.worshipActivity);
    final repository = WorshipActivityRepository(HiveWorshipActivityBackend(box));
    final preferences = await SharedPreferences.getInstance();
    final fastingRepository = FastingRepository(preferences);
    final goals = DailyGoalsRepository(preferences).load();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final analyticsStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
    return _DashboardData(
      worship: await repository.getDailySummary(now),
      analytics: await repository.getAnalytics(start: analyticsStart, end: now),
      fastedThisMonth: fastingRepository.countStatus(FastingStatus.fasted, from: monthStart, to: now),
      fastingStreak: fastingRepository.fastedStreak(through: now),
      goals: goals,
    );
  }

  void _refresh() => setState(() => _dataFuture = _loadData());

  Future<void> _openGoals() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyGoalsScreen()));
    if (mounted) _refresh();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorshipHistoryScreen()));
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final compact = getIt<PersonalizationCubit>().state.dashboardCompact;
    return BlocBuilder<ReadingStatsCubit, ReadingStatsState>(builder: (context, reading) => FutureBuilder<_DashboardData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final activity = data?.worship;
        final goals = data?.goals ?? const DailyGoals();
        final analytics = data?.analytics;
        final summary = WorshipDashboardSummary(
          prayersCompleted: activity?.prayersCompleted ?? 0,
          prayersTotal: goals.salah > 0 ? goals.salah : 5,
          quranPages: reading.pagesToday,
          dhikrCompleted: activity?.dhikrCount ?? 0,
          dhikrGoal: goals.dhikr,
          readingStreak: reading.streak,
        );
        final quranProgress = goals.quranPages > 0 ? (summary.quranPages / goals.quranPages).clamp(0.0, 1.0) : 0.0;
        return Scaffold(
          appBar: AppBar(
            title: Text(compact ? 'Worship' : 'Worship Today'),
            centerTitle: true,
            actions: [
              IconButton(tooltip: 'History', onPressed: _openHistory, icon: const Icon(Icons.history_rounded)),
              IconButton(tooltip: 'Daily goals', onPressed: _openGoals, icon: const Icon(Icons.flag_circle_outlined)),
              IconButton(tooltip: 'Refresh', onPressed: snapshot.connectionState == ConnectionState.waiting ? null : _refresh, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _HeroCard(summary: summary, quranProgress: quranProgress),
                const SizedBox(height: 16),
                _ProgressCard(icon: Icons.menu_book_rounded, title: 'Quran', value: goals.quranPages > 0 ? '${summary.quranPages} / ${goals.quranPages} pages' : '${summary.quranPages} pages today', progress: quranProgress),
                const SizedBox(height: 12),
                _ProgressCard(icon: Icons.favorite_rounded, title: 'Dhikr', value: '${summary.dhikrCompleted} / ${summary.dhikrGoal}', progress: summary.dhikrProgress),
                const SizedBox(height: 12),
                _ProgressCard(icon: Icons.mosque_rounded, title: 'Salah', value: '${summary.prayersCompleted} / ${summary.prayersTotal} completed', progress: summary.prayerProgress),
                if (analytics != null) ...[
                  const SizedBox(height: 16),
                  _AnalyticsCard(analytics: analytics),
                ],
                if (!compact) ...[
                  const SizedBox(height: 12),
                  _ProgressCard(icon: Icons.nightlight_round, title: 'Fasting', value: '${data?.fastedThisMonth ?? 0} day${(data?.fastedThisMonth ?? 0) == 1 ? '' : 's'} this month', progress: ((data?.fastedThisMonth ?? 0) / 30).clamp(0.0, 1.0)),
                  const SizedBox(height: 16),
                  Card(child: ListTile(leading: const Icon(Icons.local_fire_department_rounded), title: const Text('Reading streak'), subtitle: Text('${summary.readingStreak} consecutive day${summary.readingStreak == 1 ? '' : 's'}'))),
                  const SizedBox(height: 10),
                  Card(child: ListTile(leading: const Icon(Icons.nightlight_outlined), title: const Text('Fasting streak'), subtitle: Text('${data?.fastingStreak ?? 0} consecutive fasted day${(data?.fastingStreak ?? 0) == 1 ? '' : 's'}'))),
                ],
                const SizedBox(height: 10),
                Card(child: ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('Daily goals'), subtitle: Text('${goals.quranPages} Quran pages • ${goals.dhikr} Dhikr • ${goals.salah} Salah'), trailing: const Icon(Icons.chevron_right_rounded), onTap: _openGoals)),
                const SizedBox(height: 10),
                if (snapshot.hasError)
                  Text('Some worship activity could not be loaded. Your existing Quran progress is still shown.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error))
                else
                  Text(compact ? 'Compact dashboard mode is enabled in Personalization.' : 'Your worship activity stays on this device. Each feature contributes to one daily view as tracking is enabled.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        );
      },
    ));
  }
}

class _DashboardData {
  const _DashboardData({required this.worship, required this.analytics, required this.fastedThisMonth, required this.fastingStreak, required this.goals});
  final WorshipDailySummary worship;
  final WorshipAnalytics analytics;
  final int fastedThisMonth;
  final int fastingStreak;
  final DailyGoals goals;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary, required this.quranProgress});
  final WorshipDashboardSummary summary;
  final double quranProgress;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = summary.prayersCompleted > 0 || summary.quranPages > 0 || summary.dhikrCompleted > 0;
    final progress = ((summary.prayerProgress + quranProgress + summary.dhikrProgress) / 3).clamp(0.0, 1.0);
    return Card(clipBehavior: Clip.antiAlias, child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primaryContainer, scheme.surfaceContainerHighest])), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(completed ? 'Keep going' : 'Begin gently', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('A simple view of today\'s worship habits.', style: Theme.of(context).textTheme.bodyMedium)])), const SizedBox(width: 16), SizedBox(width: 68, height: 68, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress), const Icon(Icons.auto_awesome_rounded)]))])));
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.analytics});
  final WorshipAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final percent = (analytics.prayerCompletionRate * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.insights_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text('Last 30 days', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              Text('${analytics.activeDays}/${analytics.days} active days', style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Metric(label: 'Salah', value: '$percent%', icon: Icons.mosque_outlined)),
              Expanded(child: _Metric(label: 'Quran', value: '${analytics.quranPages}', icon: Icons.menu_book_outlined)),
              Expanded(child: _Metric(label: 'Dhikr', value: '${analytics.dhikrCount}', icon: Icons.favorite_outline)),
            ]),
            const SizedBox(height: 12),
            Text('${analytics.prayerCompletions}/${analytics.prayerOpportunities} prayers completed • ${analytics.averageQuranPages.toStringAsFixed(1)} Quran pages/day • ${analytics.averageDhikr.toStringAsFixed(1)} Dhikr/day', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, size: 20), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(label, style: Theme.of(context).textTheme.bodySmall)]);
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.icon, required this.title, required this.value, required this.progress});
  final IconData icon;
  final String title, value;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: Padding(padding: const EdgeInsets.all(17), child: Column(children: [Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), Flexible(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodySmall))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8))]));
  }
}
