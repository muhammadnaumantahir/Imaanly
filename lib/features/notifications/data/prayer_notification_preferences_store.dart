import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/prayer_notification_preferences.dart';

/// Persists per-prayer reminder controls locally on the device.
class PrayerNotificationPreferencesStore {
  static const _boxName = 'user';
  static const _key = 'prayer_notification_preferences';

  const PrayerNotificationPreferencesStore();

  Future<PrayerNotificationPreferences> load() async {
    final box = await _openBox();
    final raw = box.get(_key);
    if (raw is Map) {
      return PrayerNotificationPreferences.fromMap(raw);
    }
    return const PrayerNotificationPreferences();
  }

  Future<void> save(PrayerNotificationPreferences preferences) async {
    final box = await _openBox();
    await box.put(_key, preferences.toMap());
  }

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
