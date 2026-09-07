import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/dhikr_reminder_scheduler.dart';

/// Settings for the optional recurring daily Dhikr reminder.
class DhikrReminderSettingsPage extends StatefulWidget {
  const DhikrReminderSettingsPage({super.key});

  @override
  State<DhikrReminderSettingsPage> createState() => _DhikrReminderSettingsPageState();
}

class _DhikrReminderSettingsPageState extends State<DhikrReminderSettingsPage> {
  static const _boxName = 'user';
  static const _enabledKey = 'dhikr_reminder_enabled';
  static const _hourKey = 'dhikr_reminder_hour';
  static const _minuteKey = 'dhikr_reminder_minute';

  final _scheduler = const DhikrReminderScheduler();
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  Future<void> _load() async {
    final box = await _box();
    if (!mounted) return;
    setState(() {
      _enabled = box.get(_enabledKey, defaultValue: false) as bool;
      _time = TimeOfDay(
        hour: (box.get(_hourKey, defaultValue: 20) as num).toInt().clamp(0, 23),
        minute: (box.get(_minuteKey, defaultValue: 0) as num).toInt().clamp(0, 59),
      );
      _loading = false;
    });
  }

  Future<void> _save() async {
    final box = await _box();
    await box.put(_enabledKey, _enabled);
    await box.put(_hourKey, _time.hour);
    await box.put(_minuteKey, _time.minute);

    if (_enabled) {
      final now = DateTime.now();
      await _scheduler.schedule(
        time: DateTime(now.year, now.month, now.day, _time.hour, _time.minute),
      );
    } else {
      await _scheduler.cancel();
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null) return;
    setState(() => _time = selected);
    await _save();
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Dhikr reminder')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Card(
            child: SwitchListTile.adaptive(
              value: _enabled,
              onChanged: _toggle,
              title: const Text('Daily reminder', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Receive a reminder every day at your chosen time.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              enabled: _enabled,
              leading: Icon(Icons.schedule_rounded, color: _enabled ? theme.colorScheme.primary : null),
              title: const Text('Reminder time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _enabled ? _pickTime : null,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'The reminder follows your device\'s local time. You can change or disable it here at any time.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
