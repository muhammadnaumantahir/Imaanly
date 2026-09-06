import 'package:flutter/material.dart';

import 'daily_goals_screen.dart';

/// Small navigation entry point for Imaanly's daily worship goals.
class DailyGoalsLauncherScreen extends StatelessWidget {
  const DailyGoalsLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_circle_outlined),
        title: const Text('Daily Goals'),
        subtitle: const Text('Set and adjust your personal worship targets'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DailyGoalsScreen()),
        ),
      ),
    );
  }
}
