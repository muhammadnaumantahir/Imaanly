import 'package:flutter/material.dart';

import 'dhikr_controller.dart';
import 'dhikr_reminder_settings_page.dart';

/// Focused, offline-first Dhikr counter screen.
class DhikrPage extends StatefulWidget {
  const DhikrPage({super.key});

  @override
  State<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends State<DhikrPage> {
  late final DhikrController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DhikrController()..load();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _changeGoal() async {
    final options = [33, 99, 100, 300, 500, 1000];
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text('Daily Dhikr target', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            ...options.map((value) => ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text('$value repetitions'),
              trailing: value == _controller.progress.goal ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, value),
            )),
          ],
        ),
      ),
    );
    if (selected != null) await _controller.setGoal(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _controller.progress;
    final percent = (progress.completion * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr'),
        actions: [
          IconButton(
            tooltip: 'Daily target',
            onPressed: _controller.loading || _controller.busy ? null : _changeGoal,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Dhikr reminder',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DhikrReminderSettingsPage()),
            ),
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: theme.colorScheme.primary, size: 32),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${_controller.streak} day streak', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          const Text('Keep your remembrance consistent.'),
                        ])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CircularProgressIndicator(
                              value: progress.completion,
                              strokeWidth: 18,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('${progress.completed}', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800)),
                            Text('of ${progress.goal}', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('$percent% complete', style: theme.textTheme.bodySmall),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    progress.isGoalComplete ? 'Alhamdulillah — target complete!' : '${progress.remaining} repetitions remaining',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 72,
                    child: FilledButton(
                      onPressed: progress.isGoalComplete || _controller.busy ? null : () => _controller.increment(),
                      style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                      child: const Icon(Icons.touch_app_rounded, size: 34),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Tap to count', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Daily target'),
                      subtitle: Text('${progress.goal} repetitions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _controller.busy ? null : _changeGoal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Daily reminder'),
                      subtitle: const Text('Choose a recurring reminder time'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DhikrReminderSettingsPage()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
