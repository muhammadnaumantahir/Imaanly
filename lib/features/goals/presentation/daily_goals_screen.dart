import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/daily_goals_repository.dart';
import '../domain/daily_goals.dart';

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
          decoration: const InputDecoration(labelText: 'Daily target', suffixText: 'per day'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Set small, sustainable worship targets. These goals are stored locally on this device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GoalTile(
            icon: Icons.menu_book_rounded,
            title: 'Quran pages',
            value: _goals.quranPages,
            onEdit: () => _edit('Quran pages', _goals.quranPages, (v) => _goals = _goals.copyWith(quranPages: v)),
          ),
          _GoalTile(
            icon: Icons.format_list_numbered_rounded,
            title: 'Quran ayahs',
            value: _goals.quranAyahs,
            onEdit: () => _edit('Quran ayahs', _goals.quranAyahs, (v) => _goals = _goals.copyWith(quranAyahs: v)),
          ),
          _GoalTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Dhikr',
            value: _goals.dhikr,
            onEdit: () => _edit('Dhikr', _goals.dhikr, (v) => _goals = _goals.copyWith(dhikr: v)),
          ),
          _GoalTile(
            icon: Icons.mosque_outlined,
            title: 'Salah',
            value: _goals.salah,
            onEdit: () => _edit('Salah', _goals.salah, (v) => _goals = _goals.copyWith(salah: v.clamp(0, 5))),
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
  const _GoalTile({required this.icon, required this.title, required this.value, required this.onEdit});

  final IconData icon;
  final String title;
  final int value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value == 0 ? 'Disabled' : '$value per day'),
          trailing: IconButton(icon: const Icon(Icons.edit_rounded), tooltip: 'Edit goal', onPressed: onEdit),
        ),
      );
}
