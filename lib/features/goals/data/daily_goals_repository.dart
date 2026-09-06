import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/daily_goals.dart';

class DailyGoalsRepository {
  DailyGoalsRepository(this._preferences);

  static const _key = 'imaanly.daily_goals.v1';
  final SharedPreferences _preferences;

  DailyGoals load() {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const DailyGoals();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return DailyGoals.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Fall back to safe defaults when persisted data is malformed.
    }
    return const DailyGoals();
  }

  Future<void> save(DailyGoals goals) {
    return _preferences.setString(_key, jsonEncode(goals.toJson()));
  }
}
