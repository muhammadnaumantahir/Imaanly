import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';

import '../domain/daily_goals.dart';

class DailyGoalsRepository {
  DailyGoalsRepository(this._preferences);

  static const _key = 'imaanly.daily_goals.v1';
  final SharedPreferences _preferences;

  DailyGoals load() {
    final raw = _preferences.getString(_key);
    DailyGoals goals;
    if (raw == null || raw.isEmpty) {
      goals = const DailyGoals();
    } else {
      try {
        final decoded = jsonDecode(raw);
        goals = decoded is Map
            ? DailyGoals.fromJson(Map<String, dynamic>.from(decoded))
            : const DailyGoals();
      } catch (_) {
        // Fall back to safe defaults when persisted data is malformed.
        goals = const DailyGoals();
      }
    }

    // Personalization is the app-level source of truth for the user's Dhikr
    // target. Other goal consumers (dashboard/background notifications/etc.)
    // already read through this repository, so they inherit the preference
    // without duplicating synchronization logic.
    final personalizationRaw =
        _preferences.getString('imaanly.personalization.v1');
    if (personalizationRaw == null || personalizationRaw.isEmpty) return goals;

    try {
      final personalization = ImaanlyPersonalization.decode(personalizationRaw);
      return goals.copyWith(dhikr: personalization.dhikrDailyGoal);
    } catch (_) {
      return goals;
    }
  }

  Future<void> save(DailyGoals goals) {
    return _preferences.setString(_key, jsonEncode(goals.toJson()));
  }
}
