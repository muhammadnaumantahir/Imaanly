import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:imaanly/features/fasting/data/fasting_repository.dart';
import 'package:imaanly/features/fasting/domain/fasting_entry.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key, required this.repository});

  final FastingRepository repository;

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  late DateTime _selectedDate;
  late FastingEntry? _entry;

  @override
  void initState() {
    super.initState();
    _selectedDate = _day(DateTime.now());
    _entry = widget.repository.forDate(_selectedDate);
  }

  void _selectDate(DateTime date) {
    final selected = _day(date);
    setState(() {
      _selectedDate = selected;
      _entry = widget.repository.forDate(selected);
    });
  }

  Future<void> _save(FastingStatus status) async {
    final note = _entry?.note;
    final entry = FastingEntry(date: _selectedDate, status: status, note: note);
    await widget.repository.save(entry);
    if (!mounted) return;
    setState(() => _entry = entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status == FastingStatus.fasted ? 'Fasting day recorded.' : 'Fasting status updated.')),
    );
  }

  Future<void> _remove() async {
    await widget.repository.remove(_selectedDate);
    if (!mounted) return;
    setState(() => _entry = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = _day(DateTime.now());
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final monthFasted = widget.repository.countStatus(FastingStatus.fasted, from: monthStart, to: monthEnd);
    final streak = widget.repository.fastedStreak(through: today);

    return Scaffold(
      appBar: AppBar(title: const Text('Fasting Tracker')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, scheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fasting journal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Keep a private record of your fasting days and personal notes.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                Row(children: [
                  _Stat(label: 'This month', value: '$monthFasted'),
                  const SizedBox(width: 10),
                  _Stat(label: 'Current streak', value: '$streak'),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconButton(onPressed: () => _selectDate(_selectedDate.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat('EEE, d MMMM yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedDate.isBefore(today) ? () => _selectDate(_selectedDate.add(const Duration(days: 1))) : null,
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
                  emptySelectionAllowed: false,
                ),
                const SizedBox(height: 12),
                if (_entry != null)
                  Row(children: [
                    Icon(Icons.check_circle_rounded, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('Recorded as ${_entry!.status.name}.', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(onPressed: _remove, child: const Text('Clear')),
                  ]),
                if (_entry == null)
                  Text('No fasting status recorded for this day yet.', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Useful journal habit', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Use the tracker for your own record keeping. Religious rulings and exemptions should be taken from a trusted qualified scholar.', style: Theme.of(context).textTheme.bodyMedium),
              ]),
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
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: scheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ]),
      ),
    );
  }
}
