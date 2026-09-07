import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/fasting_reminder_preferences.dart';
import '../data/fasting_reminder_scheduler.dart';
import '../data/fasting_repository.dart';
import '../domain/fasting_entry.dart';
import '../../notifications/services/local_notification_service.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key, required this.repository});

  final FastingRepository repository;

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  late DateTime _selectedDate;
  FastingEntry? _entry;
  FastingReminderPreferences _reminder =
      const FastingReminderPreferences(enabled: false, hour: 19, minute: 0);
  final FastingReminderScheduler _scheduler = FastingReminderScheduler();

  @override
  void initState() {
    super.initState();
    _selectedDate = _day(DateTime.now());
    _entry = widget.repository.forDate(_selectedDate);
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final value = await FastingReminderPreferences.load();
    if (mounted) setState(() => _reminder = value);
  }

  void _selectDate(DateTime date) {
    final selected = _day(date);
    setState(() {
      _selectedDate = selected;
      _entry = widget.repository.forDate(selected);
    });
  }

  Future<void> _save(FastingStatus status) async {
    final entry = FastingEntry(
      date: _selectedDate,
      status: status,
      note: _entry?.note,
    );
    await widget.repository.save(entry);
    if (!mounted) return;
    setState(() => _entry = entry);
  }

  Future<void> _remove() async {
    await widget.repository.remove(_selectedDate);
    if (mounted) setState(() => _entry = null);
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _entry?.note ?? '');
    final note = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Private note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 500,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Add a personal journal note'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (note == null || !mounted) return;
    final entry = FastingEntry(
      date: _selectedDate,
      status: _entry?.status ?? FastingStatus.fasted,
      note: note.isEmpty ? null : note,
    );
    await widget.repository.save(entry);
    if (mounted) setState(() => _entry = entry);
  }

  Future<void> _toggleReminder(bool enabled) async {
    final next = _reminder.copyWith(enabled: enabled);
    if (enabled) {
      final granted = await LocalNotificationService.instance.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission was not granted.')),
          );
        }
        return;
      }
      await _scheduler.schedule(
        time: DateTime(2000, 1, 1, next.hour, next.minute),
      );
    } else {
      await _scheduler.cancel();
    }
    await next.save();
    if (mounted) setState(() => _reminder = next);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminder.hour, minute: _reminder.minute),
    );
    if (picked == null) return;
    final next = _reminder.copyWith(hour: picked.hour, minute: picked.minute);
    if (next.enabled) {
      await _scheduler.schedule(
        time: DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    }
    await next.save();
    if (mounted) setState(() => _reminder = next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = _day(DateTime.now());
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final monthFasted = widget.repository.countStatus(
      FastingStatus.fasted,
      from: monthStart,
      to: monthEnd,
    );
    final streak = widget.repository.fastedStreak(through: today);

    return Scaffold(
      appBar: AppBar(title: const Text('Fasting Tracker')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fasting journal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Keep a private record of your fasting days and personal notes.'),
                  const SizedBox(height: 18),
                  Row(children: [
                    _Stat(label: 'This month', value: '$monthFasted'),
                    const SizedBox(width: 10),
                    _Stat(label: 'Current streak', value: '$streak'),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                      onPressed: () => _selectDate(_selectedDate.subtract(const Duration(days: 1))),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          DateFormat('EEE, d MMMM yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _selectedDate.isBefore(today)
                          ? () => _selectDate(_selectedDate.add(const Duration(days: 1)))
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  SegmentedButton<FastingStatus>(
                    segments: const [
                      ButtonSegment(value: FastingStatus.fasted, icon: Icon(Icons.check_circle_outline), label: Text('Fasted')),
                      ButtonSegment(value: FastingStatus.missed, icon: Icon(Icons.remove_circle_outline), label: Text('Missed')),
                      ButtonSegment(value: FastingStatus.excused, icon: Icon(Icons.info_outline), label: Text('Excused')),
                    ],
                    selected: {_entry?.status ?? FastingStatus.missed},
                    onSelectionChanged: (selection) => _save(selection.first),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(_entry == null ? Icons.radio_button_unchecked : Icons.check_circle_rounded, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_entry == null ? 'No status recorded for this day.' : 'Recorded as ${_entry!.status.name}.')),
                    if (_entry != null) TextButton(onPressed: _remove, child: const Text('Clear')),
                  ]),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(onPressed: _editNote, icon: const Icon(Icons.edit_note_rounded), label: Text(_entry?.note?.isNotEmpty == true ? 'Edit private note' : 'Add private note')),
                  if (_entry?.note?.isNotEmpty == true)
                    Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(top: 10), child: Text(_entry!.note!))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Row(children: [
                  Icon(Icons.notifications_active_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Daily fasting check-in', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 3),
                    Text('Optional reminder to record your own fasting status.'),
                  ])),
                  Switch(value: _reminder.enabled, onChanged: _toggleReminder),
                ]),
                if (_reminder.enabled) ...[
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_rounded),
                    title: const Text('Reminder time'),
                    subtitle: Text(TimeOfDay(hour: _reminder.hour, minute: _reminder.minute).format(context)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickReminderTime,
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Use the tracker for your own record keeping. Religious rulings and exemptions should be taken from a trusted qualified scholar.'),
            ),
          ),
        ],
      ),
    );
  }

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ]),
      ),
    );
  }
}
