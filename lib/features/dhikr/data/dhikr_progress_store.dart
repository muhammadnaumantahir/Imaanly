import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/dhikr_progress.dart';

class DhikrProgressStore {
  static const _boxName = 'user';
  static const _progressKey = 'dhikr_progress';
  static const _completedDatesKey = 'dhikr_completed_dates';

  const DhikrProgressStore();

  Future<DhikrProgress> load([DateTime? date]) async {
    final box = await _openBox();
    final raw = box.get(_progressKey);
    final stored = raw is Map
        ? DhikrProgress.fromMap(raw)
        : const DhikrProgress(goal: 33, completed: 0);
    return stored.forDate(date ?? DateTime.now());
  }

  Future<void> save(DhikrProgress progress) async {
    final box = await _openBox();
    await box.put(_progressKey, progress.toMap());
    if (progress.isGoalComplete && progress.dateKey.isNotEmpty) {
      final dates = _readDates(box);
      dates.add(progress.dateKey);
      await box.put(_completedDatesKey, dates.toList());
    }
  }

  Future<DhikrProgress> increment({int amount = 1, DateTime? date}) async {
    final progress = await load(date);
    final next = progress.increment(amount);
    await save(next);
    return next;
  }

  Future<void> setGoal(int goal, {DateTime? date}) async {
    final safeGoal = goal.clamp(1, 100000).toInt();
    final progress = await load(date);
    await save(DhikrProgress(
      goal: safeGoal,
      completed: progress.completed.clamp(0, safeGoal),
      dateKey: progress.dateKey,
    ));
  }

  Future<Set<String>> loadCompletedDates() async {
    final box = await _openBox();
    return _readDates(box);
  }

  Future<int> loadCurrentStreak([DateTime? today]) async {
    return DhikrStreakCalculator.calculate(
      completedDates: await loadCompletedDates(),
      today: today ?? DateTime.now(),
    );
  }

  Set<String> _readDates(Box box) {
    final raw = box.get(_completedDatesKey);
    if (raw is Iterable) return raw.map((value) => value.toString()).toSet();
    return <String>{};
  }

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
