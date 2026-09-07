import 'package:flutter/material.dart';

import '../data/smart_notification_coordinator.dart';
import '../domain/smart_notification_preferences.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  final _coordinator = SmartNotificationCoordinator();
  SmartNotificationPreferences _preferences =
      const SmartNotificationPreferences();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _coordinator.loadPreferences();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _loading = false;
    });
  }

  Future<void> _save(SmartNotificationPreferences next) async {
    setState(() {
      _preferences = next;
      _saving = true;
    });
    await _coordinator.savePreferences(next);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _pickHour({required bool start}) async {
    final current = TimeOfDay(
      hour: start ? _preferences.quietStartHour : _preferences.quietEndHour,
      minute: 0,
    );
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await _save(_preferences.copyWith(
      quietStartHour: start ? picked.hour : null,
      quietEndHour: start ? null : picked.hour,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                const Text(
                  'Choose what Imaanly can remind you about. Your choices stay on this device.',
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      _toggle(
                        'Prayer reminders',
                        'Stay aware of upcoming prayers',
                        Icons.mosque_outlined,
                        _preferences.prayerEnabled,
                        (value) => _save(
                          _preferences.copyWith(prayerEnabled: value),
                        ),
                      ),
                      _toggle(
                        'Quran',
                        'Gentle reading prompts',
                        Icons.menu_book_outlined,
                        _preferences.quranEnabled,
                        (value) => _save(
                          _preferences.copyWith(quranEnabled: value),
                        ),
                      ),
                      _toggle(
                        'Dhikr',
                        'Keep your daily dhikr goal in sight',
                        Icons.favorite_border,
                        _preferences.dhikrEnabled,
                        (value) => _save(
                          _preferences.copyWith(dhikrEnabled: value),
                        ),
                      ),
                      _toggle(
                        'Streaks',
                        'Encouragement when your worship streak needs attention',
                        Icons.local_fire_department_outlined,
                        _preferences.streakEnabled,
                        (value) => _save(
                          _preferences.copyWith(streakEnabled: value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Daily limit'),
                        subtitle: Text(
                          '${_preferences.maxNotificationsPerDay} notification${_preferences.maxNotificationsPerDay == 1 ? '' : 's'} per day',
                        ),
                        trailing: DropdownButton<int>(
                          value: _preferences.maxNotificationsPerDay,
                          items: [0, 1, 2, 3, 5].map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _save(_preferences.copyWith(
                                maxNotificationsPerDay: value,
                              ));
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bedtime_outlined),
                        title: const Text('Quiet hours'),
                        subtitle: Text(
                          '${_formatHour(_preferences.quietStartHour)} – ${_formatHour(_preferences.quietEndHour)}',
                        ),
                        trailing: TextButton(
                          onPressed: () => _pickHour(start: true),
                          child: const Text('Change'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _pickHour(start: true),
                              child: Text(_formatHour(_preferences.quietStartHour)),
                            ),
                            const Text('to'),
                            TextButton(
                              onPressed: () => _pickHour(start: false),
                              child: Text(_formatHour(_preferences.quietEndHour)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Quiet hours suppress smart reminders during the selected period. Prayer scheduling itself is not changed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  String _formatHour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final normalized = hour % 12 == 0 ? 12 : hour % 12;
    return '$normalized:00 $suffix';
  }
}
