import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/presentation/worship_analytics_screen.dart';
import '../data/daily_goals_repository.dart';
import '../domain/daily_goals.dart';
import 'package:imaanly/src/theme/app_widgets.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  late DailyGoalsRepository _repository;
  late DailyGoals _goals;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final preferences = await SharedPreferences.getInstance();
    _repository = DailyGoalsRepository(preferences);
    _goals = _repository.load();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _edit(String title, int initial, ValueChanged<int> apply) async {
    final controller = TextEditingController(text: initial.toString());
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily target',
            suffixText: 'per day',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || value == null) return;
    final safe = value.clamp(0, 100000);
    apply(safe);
    await _repository.save(_goals);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Goals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flag_rounded, color: Color(0xFFE2BC6B), size: 30),
                const SizedBox(height: 12),
                Text(
                  'Daily goals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set small, sustainable worship targets. These goals are stored locally on this device.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GoalTile(
            icon: Icons.menu_book_rounded,
            title: 'Quran pages',
            value: _goals.quranPages,
            onEdit: () => _edit(
              'Quran pages',
              _goals.quranPages,
              (v) => _goals = _goals.copyWith(quranPages: v),
            ),
          ),
          _GoalTile(
            icon: Icons.format_list_numbered_rounded,
            title: 'Quran ayahs',
            value: _goals.quranAyahs,
            onEdit: () => _edit(
              'Quran ayahs',
              _goals.quranAyahs,
              (v) => _goals = _goals.copyWith(quranAyahs: v),
            ),
          ),
          _GoalTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Dhikr',
            value: _goals.dhikr,
            onEdit: () => _edit(
              'Dhikr',
              _goals.dhikr,
              (v) => _goals = _goals.copyWith(dhikr: v),
            ),
          ),
          _GoalTile(
            icon: Icons.mosque_outlined,
            title: 'Salah',
            value: _goals.salah,
            onEdit: () => _edit(
              'Salah',
              _goals.salah,
              (v) => _goals = _goals.copyWith(salah: v.clamp(0, 5)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Worship insights'),
              subtitle: const Text(
                'Review your last 7 days of worship activity',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorshipAnalyticsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '0 means that goal is disabled.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final int value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              IconBadge(icon: icon, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      value == 0 ? 'Disabled' : '$value per day',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.edit_rounded, size: 18),
                tooltip: 'Edit goal',
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      );
}
