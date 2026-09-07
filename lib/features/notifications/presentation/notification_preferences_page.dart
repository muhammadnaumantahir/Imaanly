import 'package:flutter/material.dart';

import '../data/prayer_notification_preferences_store.dart';
import '../data/smart_notification_coordinator.dart';
import '../domain/prayer_notification_preferences.dart';
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
  final _prayerStore = const PrayerNotificationPreferencesStore();
  SmartNotificationPreferences _preferences =
      const SmartNotificationPreferences();
  PrayerNotificationPreferences _prayerPreferences =
      const PrayerNotificationPreferences();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _coordinator.loadPreferences();
    final prayerPreferences = await _prayerStore.load();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _prayerPreferences = prayerPreferences;
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

  Future<void> _savePrayer(PrayerNotificationPreferences next) async {
    setState(() {
      _prayerPreferences = next;
      _saving = true;
    });
    await _prayerStore.save(next);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _pickHour({required bool start}) async {
    final current = TimeOfDay(
      hour: start ? _preferences.quietStartHour : _preferences.quietEndHour,
      minute: 0,
    );
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    final next = start
        ? _preferences.copyWith(quietStartHour: picked.hour)
        : _preferences.copyWith(quietEndHour: picked.hour);
    await _save(next);
  }

  Future<void> _pickReminderMinutes() async {
    final options = [0, 5, 10, 15, 20, 30, 45, 60];
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: options
              .map(
                (minutes) => ListTile(
                  title: Text(
                    minutes == 0 ? 'At prayer time' : '$minutes minutes before',
                  ),
                  trailing: minutes == _prayerPreferences.reminderMinutes
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, minutes),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      await _savePrayer(_prayerPreferences.copyWith(reminderMinutes: selected));
    }
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
                      _toggle('Prayer reminders', 'Stay aware of upcoming prayers', Icons.mosque_outlined, _preferences.prayerEnabled, (value) => _save(_preferences.copyWith(prayerEnabled: value))),
                      _toggle('Quran', 'Gentle reading prompts', Icons.menu_book_outlined, _preferences.quranEnabled, (value) => _save(_preferences.copyWith(quranEnabled: value))),
                      _toggle('Dhikr', 'Keep your daily dhikr goal in sight', Icons.favorite_border, _preferences.dhikrEnabled, (value) => _save(_preferences.copyWith(dhikrEnabled: value))),
                      _toggle('Streaks', 'Encouragement when your worship streak needs attention', Icons.local_fire_department_outlined, _preferences.streakEnabled, (value) => _save(_preferences.copyWith(streakEnabled: value))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.mosque_outlined),
                        title: Text('Prayer schedule'),
                        subtitle: Text('Control reminders for each salah independently.'),
                      ),
                      _prayerToggle('Fajr', _prayerPreferences.fajr, (value) => _savePrayer(_prayerPreferences.copyWith(fajr: value))),
                      _prayerToggle('Dhuhr', _prayerPreferences.dhuhr, (value) => _savePrayer(_prayerPreferences.copyWith(dhuhr: value))),
                      _prayerToggle('Asr', _prayerPreferences.asr, (value) => _savePrayer(_prayerPreferences.copyWith(asr: value))),
                      _prayerToggle('Maghrib', _prayerPreferences.maghrib, (value) => _savePrayer(_prayerPreferences.copyWith(maghrib: value))),
                      _prayerToggle('Isha', _prayerPreferences.isha, (value) => _savePrayer(_prayerPreferences.copyWith(isha: value))),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: const Text('Reminder time'),
                        subtitle: Text(_prayerPreferences.reminderMinutes == 0
                            ? 'At prayer time'
                            : '${_prayerPreferences.reminderMinutes} minutes before each prayer'),
                        trailing: TextButton(
                          onPressed: _pickReminderMinutes,
                          child: const Text('Change'),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        secondary: const Icon(Icons.volume_off_outlined),
                        title: const Text('Silent prayer reminders'),
                        subtitle: const Text('Use notification delivery without a sound.'),
                        value: _prayerPreferences.silent,
                        onChanged: (value) => _savePrayer(
                          _prayerPreferences.copyWith(silent: value),
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
                        subtitle: Text('${_preferences.maxNotificationsPerDay} notification${_preferences.maxNotificationsPerDay == 1 ? '' : 's'} per day'),
                        trailing: DropdownButton<int>(
                          value: _preferences.maxNotificationsPerDay,
                          items: [0, 1, 2, 3, 5].map((value) => DropdownMenuItem(value: value, child: Text('$value'))).toList(),
                          onChanged: (value) { if (value != null) _save(_preferences.copyWith(maxNotificationsPerDay: value)); },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bedtime_outlined),
                        title: const Text('Quiet hours'),
                        subtitle: Text('${_formatHour(_preferences.quietStartHour)} – ${_formatHour(_preferences.quietEndHour)}'),
                        trailing: TextButton(onPressed: () => _pickHour(start: true), child: const Text('Change')),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => _pickHour(start: true), child: Text(_formatHour(_preferences.quietStartHour))),
                            const Text('to'),
                            TextButton(onPressed: () => _pickHour(start: false), child: Text(_formatHour(_preferences.quietEndHour))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Quiet hours suppress smart reminders during the selected period. Prayer scheduling is controlled separately above.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
    );
  }

  Widget _toggle(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _prayerToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      title: Text(title),
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
