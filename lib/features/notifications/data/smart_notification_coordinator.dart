import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/smart_notification.dart';
import '../domain/smart_notification_preferences.dart';

/// Coordinates local notification policy with persistence and fatigue limits.
///
/// Delivery is injected so this layer remains platform-agnostic and testable.
class SmartNotificationCoordinator {
  SmartNotificationCoordinator({
    Future<void> Function(SmartNotificationCandidate candidate)? deliver,
    SmartNotificationPreferences preferences = const SmartNotificationPreferences(),
  })  : _deliver = deliver,
        _preferences = preferences;

  static const _boxName = 'user';
  static const _preferencesKey = 'smart_notification_preferences';
  static const _sentDateKey = 'smart_notification_sent_date';
  static const _sentCountKey = 'smart_notification_sent_count';

  final Future<void> Function(SmartNotificationCandidate candidate)? _deliver;
  SmartNotificationPreferences _preferences;
  final SmartNotificationPlanner _planner = const SmartNotificationPlanner();

  SmartNotificationPreferences get preferences => _preferences;

  /// Loads saved preferences from Hive, falling back to [preferences].
  Future<SmartNotificationPreferences> loadPreferences() async {
    final box = await _openBox();
    final raw = box.get(_preferencesKey);
    if (raw is Map) {
      _preferences = SmartNotificationPreferences.fromMap(raw);
    }
    return _preferences;
  }

  /// Saves preferences locally and makes them the active policy.
  Future<void> savePreferences(SmartNotificationPreferences preferences) async {
    _preferences = preferences;
    final box = await _openBox();
    await box.put(_preferencesKey, preferences.toMap());
  }

  Future<SmartNotificationCandidate?> evaluateAndDeliver({
    required DateTime now,
    DateTime? nextPrayerAt,
    String? nextPrayerName,
    required int quranMinutesToday,
    int quranGoalMinutes = 0,
    required int dhikrCompletedToday,
    int dhikrGoal = 0,
    int currentStreak = 0,
    DateTime? lastActiveDay,
    SmartNotificationPreferences? preferences,
    Future<void> Function(SmartNotificationCandidate candidate)? deliver,
  }) async {
    final effectivePreferences = preferences ?? _preferences;
    if (!await canNotify(now, preferences: effectivePreferences)) return null;

    final candidate = _planner.evaluate(
      now: now,
      nextPrayerAt: nextPrayerAt,
      nextPrayerName: nextPrayerName,
      quranMinutesToday: quranMinutesToday,
      quranGoalMinutes: quranGoalMinutes,
      dhikrCompletedToday: dhikrCompletedToday,
      dhikrGoal: dhikrGoal,
      currentStreak: currentStreak,
      lastActiveDay: lastActiveDay,
      preferences: effectivePreferences,
    );
    if (candidate == null) return null;

    await _recordSent(now);
    await (deliver ?? _deliver)?.call(candidate);
    return candidate;
  }

  Future<bool> canNotify(
    DateTime now, {
    SmartNotificationPreferences? preferences,
  }) async {
    final effectivePreferences = preferences ?? _preferences;
    if (effectivePreferences.maxNotificationsPerDay <= 0 ||
        !effectivePreferences.isEnabledForAnyCategory ||
        effectivePreferences.isQuietHour(now)) {
      return false;
    }
    final box = await _openBox();
    final today = _dayKey(now);
    final sentDate = box.get(_sentDateKey)?.toString();
    final count = sentDate == today ? (box.get(_sentCountKey) as num?)?.toInt() ?? 0 : 0;
    return count < effectivePreferences.maxNotificationsPerDay;
  }

  Future<void> _recordSent(DateTime now) async {
    final box = await _openBox();
    final today = _dayKey(now);
    final sentDate = box.get(_sentDateKey)?.toString();
    final count = sentDate == today ? (box.get(_sentCountKey) as num?)?.toInt() ?? 0 : 0;
    await box.put(_sentDateKey, today);
    await box.put(_sentCountKey, count + 1);
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}

extension on SmartNotificationPreferences {
  bool get isEnabledForAnyCategory =>
      prayerEnabled || quranEnabled || dhikrEnabled || streakEnabled;
}
