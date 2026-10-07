import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which of the five daily prayers were prayed, per day.
///
/// Each day is stored as a 5-bit mask (bit 0 = Fajr ... bit 4 = Isha) under a
/// `yyyy-MM-dd` key, so the whole history stays tiny.
class PrayerTrackerStore extends ChangeNotifier {
  PrayerTrackerStore._();

  static final PrayerTrackerStore instance = PrayerTrackerStore._();

  static const String _prefsKey = 'prayer_tracker_v1';
  static const List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  final Map<String, int> _days = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  static String keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        map.forEach((k, v) {
          if (v is int) _days[k] = v;
        });
      } catch (_) {
        // Ignore corrupt data and start fresh.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_days));
  }

  bool isDone(DateTime day, int prayer) {
    final mask = _days[keyFor(day)] ?? 0;
    return ((mask >> prayer) & 1) == 1;
  }

  int doneCount(DateTime day) {
    final mask = _days[keyFor(day)] ?? 0;
    var count = 0;
    for (var i = 0; i < 5; i++) {
      if (((mask >> i) & 1) == 1) count++;
    }
    return count;
  }

  bool isComplete(DateTime day) => doneCount(day) == 5;

  Future<void> toggle(DateTime day, int prayer) async {
    final key = keyFor(day);
    final next = (_days[key] ?? 0) ^ (1 << prayer);
    if (next == 0) {
      _days.remove(key);
    } else {
      _days[key] = next;
    }
    notifyListeners();
    await _save();
  }

  /// Consecutive fully-completed days ending today (or yesterday, if today is
  /// still in progress).
  int currentStreak(DateTime today) {
    var day = dateOnly(today);
    if (!isComplete(day)) day = addDays(day, -1);
    var streak = 0;
    while (isComplete(day)) {
      streak++;
      day = addDays(day, -1);
    }
    return streak;
  }

  int bestStreak() {
    final complete = _days.entries
        .where((e) => e.value == 31)
        .map((e) => DateTime.tryParse(e.key))
        .whereType<DateTime>()
        .toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final d in complete) {
      if (previous != null && dateOnly(d) == addDays(previous, 1)) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      previous = dateOnly(d);
    }
    return best;
  }

  /// Completed-prayer counts for the last [days] days, oldest first.
  List<int> lastDays(DateTime today, int days) {
    final end = dateOnly(today);
    return [
      for (var i = days - 1; i >= 0; i--) doneCount(addDays(end, -i)),
    ];
  }

  int totalPrayed() {
    var total = 0;
    for (final mask in _days.values) {
      for (var i = 0; i < 5; i++) {
        if (((mask >> i) & 1) == 1) total++;
      }
    }
    return total;
  }
}
