import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/reading_stats/reading_stats_cubit.dart';

class QuranReadingProgressScreen extends StatelessWidget {
  const QuranReadingProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReadingStatsCubit(),
      child: const _QuranReadingProgressView(),
    );
  }
}

class _QuranReadingProgressView extends StatelessWidget {
  const _QuranReadingProgressView();

  Future<void> _setGoal(BuildContext context, ReadingStatsState state) async {
    final controller = TextEditingController(text: state.dailyGoalPages > 0 ? '${state.dailyGoalPages}' : '');
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Daily Quran goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Pages per day', hintText: 'e.g. 5', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, 0), child: const Text('Clear')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, int.tryParse(controller.text.trim())), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || value == null) return;
    context.read<ReadingStatsCubit>().setDailyGoal(pages: value.clamp(0, 604).toInt());
  }

  List<ReadingHistoryDay> _lastSevenDays(ReadingStatsState state) {
    final byDate = {for (final day in state.history) day.date: day};
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return byDate[key] ?? ReadingHistoryDay(date: key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran Progress')),
      body: BlocBuilder<ReadingStatsCubit, ReadingStatsState>(
        builder: (context, state) {
          final days = _lastSevenDays(state);
          final maxPages = days.fold<int>(1, (max, day) => day.pages > max ? day.pages : max);
          final totalSevenDays = days.fold<int>(0, (sum, day) => sum + day.pages);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Expanded(child: Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                      IconButton(tooltip: 'Set daily goal', onPressed: () => _setGoal(context, state), icon: const Icon(Icons.flag_outlined)),
                    ]),
                    const SizedBox(height: 16),
                    Text('${state.pagesToday} pages', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${state.ayahsToday} ayat • ${state.formattedTimeToday}'),
                    if (state.hasGoal) ...[
                      const SizedBox(height: 18),
                      LinearProgressIndicator(value: state.goalProgress),
                      const SizedBox(height: 8),
                      Text(state.goalReached ? 'Daily goal reached ✓' : '${(state.dailyGoalPages - state.pagesToday).clamp(0, 604)} pages remaining'),
                    ] else ...[
                      const SizedBox(height: 14),
                      TextButton.icon(onPressed: () => _setGoal(context, state), icon: const Icon(Icons.flag_outlined), label: const Text('Set a daily page goal')),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _MetricCard(label: 'Reading streak', value: '${state.streak} days', icon: Icons.local_fire_department_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'All-time pages', value: '${state.totalPagesAllTime}', icon: Icons.menu_book_outlined)),
              ]),
              const SizedBox(height: 12),
              _MetricCard(label: 'All-time ayat', value: '${state.totalAyahsAllTime}', icon: Icons.format_list_numbered_outlined),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Last 7 days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$totalSevenDays pages read'),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        for (final day in days)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                Text('${day.pages}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                FractionallySizedBox(
                                  heightFactor: day.pages / maxPages,
                                  child: Container(
                                    constraints: const BoxConstraints(minHeight: 4),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(day.date.substring(8), style: const TextStyle(fontSize: 11)),
                              ]),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    const Text('Activity is stored locally by day, so your recent reading trend survives app restarts.'),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ])),
        ]),
      ),
    );
  }
}
