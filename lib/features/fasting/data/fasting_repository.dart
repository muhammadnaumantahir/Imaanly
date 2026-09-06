import 'dart:convert';

import 'package:imaanly/features/fasting/domain/fasting_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastingRepository {
  FastingRepository(this._preferences);

  static const _storageKey = 'imaanly.fasting.entries.v1';
  final SharedPreferences _preferences;

  List<FastingEntry> getAll() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => FastingEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return const [];
    }
  }

  FastingEntry? forDate(DateTime date) {
    final key = _key(date);
    for (final entry in getAll()) {
      if (entry.dateKey == key) return entry;
    }
    return null;
  }

  Future<void> save(FastingEntry entry) async {
    final entries = getAll().where((item) => item.dateKey != entry.dateKey).toList();
    entries.add(entry);
    entries.sort((a, b) => b.date.compareTo(a.date));
    await _preferences.setString(
      _storageKey,
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> remove(DateTime date) async {
    final key = _key(date);
    final entries = getAll().where((item) => item.dateKey != key).toList();
    await _preferences.setString(
      _storageKey,
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
  }

  int countStatus(FastingStatus status, {DateTime? from, DateTime? to}) {
    final start = from == null ? null : DateTime(from.year, from.month, from.day);
    final end = to == null ? null : DateTime(to.year, to.month, to.day);
    return getAll().where((entry) {
      if (entry.status != status) return false;
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (start != null && day.isBefore(start)) return false;
      if (end != null && day.isAfter(end)) return false;
      return true;
    }).length;
  }

  int fastedStreak({DateTime? through}) {
    var day = through == null
        ? DateTime.now()
        : DateTime(through.year, through.month, through.day);
    var streak = 0;
    while (forDate(day)?.status == FastingStatus.fasted) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _key(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
