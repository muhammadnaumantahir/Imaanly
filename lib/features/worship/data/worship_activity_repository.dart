import 'package:hive_ce/hive.dart';

import 'package:imaanly/src/core/storage/app_boxes.dart';
import '../domain/worship_activity.dart';
import '../domain/worship_analytics.dart';
import '../domain/worship_daily_summary.dart';

abstract interface class WorshipActivityBackend {
  Future<void> put(WorshipActivity activity);
  Future<List<WorshipActivity>> values();
}

/// Local Hive-backed persistence for worship events.
///
/// The repository is intentionally small: worship features record events here,
/// while the domain layer owns aggregation and progress rules.
class WorshipActivityRepository {
  WorshipActivityRepository(this._backend);

  final WorshipActivityBackend _backend;

  static Future<WorshipActivityRepository> openLocal() async {
    final box = Hive.isBoxOpen(AppBoxes.worshipActivity)
        ? Hive.box<Map>(AppBoxes.worshipActivity)
        : await Hive.openBox<Map>(AppBoxes.worshipActivity);
    return WorshipActivityRepository(HiveWorshipActivityBackend(box));
  }

  Future<void> record(WorshipActivity activity) => _backend.put(activity);

  /// Persists the current cumulative Dhikr progress for one category/day.
  ///
  /// This is deliberately an upsert rather than a new event on every tap.
  /// The existing Dhikr screen stores a cumulative daily counter, so recording
  /// snapshots prevents the worship dashboard from double-counting every tap.
  Future<void> upsertDailyDhikr({
    required String category,
    required int completed,
    required int goal,
    DateTime? date,
  }) async {
    if (completed < 0) {
      throw ArgumentError.value(completed, 'completed', 'must not be negative');
    }
    if (goal < 0) {
      throw ArgumentError.value(goal, 'goal', 'must not be negative');
    }

    final recordedAt = date ?? DateTime.now();
    final day = WorshipActivity.dayKey(recordedAt);
    final activity = WorshipActivity(
      id: 'dhikr:$day:$category',
      type: WorshipActivityType.dhikr,
      dateKey: day,
      recordedAt: recordedAt,
      amount: completed,
      target: goal,
      reference: category,
    );
    await record(activity);
  }

  Future<List<WorshipActivity>> getAll() => _backend.values();

  Future<WorshipDailySummary> getDailySummary(DateTime date) async {
    return WorshipDailySummary.fromActivities(await getAll(), date: date);
  }

  /// Returns one summary per calendar day, oldest first.
  Future<List<WorshipDailySummary>> getDailySummaries({
    required DateTime start,
    required DateTime end,
  }) async {
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    if (last.isBefore(first)) {
      throw ArgumentError('end must be on or after start');
    }

    final activities = await getAll();
    final summaries = <WorshipDailySummary>[];
    for (var day = first; !day.isAfter(last); day = day.add(const Duration(days: 1))) {
      summaries.add(WorshipDailySummary.fromActivities(activities, date: day));
    }
    return List.unmodifiable(summaries);
  }

  Future<WorshipAnalytics> getAnalytics({
    required DateTime start,
    required DateTime end,
  }) async {
    final summaries = await getDailySummaries(start: start, end: end);
    return WorshipAnalytics.fromSummaries(summaries);
  }

  Future<bool> isSalahCompleted(String prayer, DateTime date) async {
    final key = WorshipActivity.salah(prayer: prayer, completedAt: date).completionKey;
    final activities = await getAll();
    return activities.any((activity) => activity.completionKey == key);
  }
}

class HiveWorshipActivityBackend implements WorshipActivityBackend {
  HiveWorshipActivityBackend(this._box);

  final Box<Map> _box;

  @override
  Future<void> put(WorshipActivity activity) async {
    await _box.put(activity.id, _toMap(activity));
  }

  @override
  Future<List<WorshipActivity>> values() async {
    return _box.values
        .map(_fromMap)
        .whereType<WorshipActivity>()
        .toList(growable: false);
  }

  Map<String, dynamic> _toMap(WorshipActivity activity) {
    return {
      'id': activity.id,
      'type': activity.type.name,
      'dateKey': activity.dateKey,
      'recordedAt': activity.recordedAt.toIso8601String(),
      'amount': activity.amount,
      'target': activity.target,
      'reference': activity.reference,
    };
  }

  WorshipActivity? _fromMap(Map raw) {
    try {
      final typeName = raw['type']?.toString();
      final type = WorshipActivityType.values.firstWhere(
        (value) => value.name == typeName,
      );
      final recordedAt = DateTime.parse(raw['recordedAt'].toString());
      return WorshipActivity(
        id: raw['id'].toString(),
        type: type,
        dateKey: raw['dateKey'].toString(),
        recordedAt: recordedAt,
        amount: (raw['amount'] as num?)?.toInt() ?? 0,
        target: (raw['target'] as num?)?.toInt(),
        reference: raw['reference']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Lightweight in-memory backend useful for domain-level tests and previews.
class MemoryWorshipActivityBackend implements WorshipActivityBackend {
  final Map<String, WorshipActivity> _activities = {};

  @override
  Future<void> put(WorshipActivity activity) async {
    _activities[activity.id] = activity;
  }

  @override
  Future<List<WorshipActivity>> values() async {
    return List.unmodifiable(_activities.values);
  }
}
