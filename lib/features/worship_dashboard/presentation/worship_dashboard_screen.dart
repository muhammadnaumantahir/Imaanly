import 'package:al_furkan/features/worship_dashboard/domain/worship_dashboard_summary.dart';
import 'package:al_furkan/src/core/reading_stats/reading_stats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// A calm daily overview that composes existing local worship data.
class WorshipDashboardScreen extends StatelessWidget {
  const WorshipDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingStatsCubit, ReadingStatsState>(
      builder: (context, reading) {
        final dhikr = _loadDhikrSummary();
        final summary = WorshipDashboardSummary(
          prayersCompleted: 0,
          prayersTotal: 5,
          quranPages: reading.pagesToday,
          dhikrCompleted: dhikr.$1,
          dhikrGoal: dhikr.$2,
          readingStreak: reading.streak,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Worship Today'), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _HeroCard(summary: summary),
              const SizedBox(height: 16),
              _ProgressCard(icon: Icons.menu_book_rounded, title: 'Quran', value: '${summary.quranPages} pages today', progress: (summary.quranPages / 5).clamp(0.0, 1.0)),
              const SizedBox(height: 12),
              _ProgressCard(icon: Icons.favorite_rounded, title: 'Dhikr', value: '${summary.dhikrCompleted} / ${summary.dhikrGoal}', progress: summary.dhikrProgress),
              const SizedBox(height: 12),
              _ProgressCard(icon: Icons.mosque_rounded, title: 'Salah', value: 'Prayer completion tracking coming next', progress: summary.prayerProgress),
              const SizedBox(height: 16),
              Card(child: ListTile(leading: const Icon(Icons.local_fire_department_rounded), title: const Text('Reading streak'), subtitle: Text('${summary.readingStreak} consecutive day${summary.readingStreak == 1 ? '' : 's'}'))),
              const SizedBox(height: 10),
              Text('Your worship data stays on this device. Statistics expand as each worship feature becomes fully trackable.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        );
      },
    );
  }

  (int, int) _loadDhikrSummary() {
    if (!Hive.isBoxOpen('user')) return (0, 33);
    final box = Hive.box('user');
    final today = _todayKey();
    var completed = 0;
    var goal = 0;
    for (final key in box.keys) {
      if (key is! String || !key.startsWith('dhikr_progress_')) continue;
      final raw = box.get(key);
      if (raw is! Map || raw['dateKey']?.toString() != today) continue;
      final c = raw['completed'];
      final g = raw['goal'];
      if (c is num) completed += c.toInt();
      if (g is num && g.toInt() > 0) goal += g.toInt();
    }
    return (completed, goal > 0 ? goal : 33);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});
  final WorshipDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = summary.quranPages > 0 || summary.dhikrCompleted > 0;
    final progress = (((summary.quranPages / 5).clamp(0.0, 1.0)) + summary.dhikrProgress) / 2;
    return Card(clipBehavior: Clip.antiAlias, child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primaryContainer, scheme.surfaceContainerHighest])), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(completed ? 'Keep going' : 'Begin gently', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('A simple view of today\'s worship habits.', style: Theme.of(context).textTheme.bodyMedium)])),
      const SizedBox(width: 16),
      SizedBox(width: 68, height: 68, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress), const Icon(Icons.auto_awesome_rounded)])),
    ])));
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.icon, required this.title, required this.value, required this.progress});
  final IconData icon; final String title; final String value; final double progress;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: Padding(padding: const EdgeInsets.all(17), child: Column(children: [
      Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), Flexible(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodySmall))]),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8)),
    ])));
  }
}
