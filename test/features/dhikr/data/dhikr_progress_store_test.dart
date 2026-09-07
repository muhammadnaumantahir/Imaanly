import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:imaanly/features/dhikr/data/dhikr_progress_store.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
  });

  setUp(() async {
    if (Hive.isBoxOpen('user')) await Hive.box('user').clear();
  });

  test('persists progress and completed-day history', () async {
    final store = const DhikrProgressStore();
    final day = DateTime(2026, 9, 7);

    await store.setGoal(3, date: day);
    await store.increment(amount: 3, date: day);

    final progress = await store.load(day);
    final dates = await store.loadCompletedDates();
    final streak = await store.loadCurrentStreak(day);

    expect(progress.completed, 3);
    expect(progress.goal, 3);
    expect(dates, contains('2026-09-07'));
    expect(streak, 1);
  });

  test('increments are capped at the daily goal', () async {
    final store = const DhikrProgressStore();
    final day = DateTime(2026, 9, 7);

    await store.setGoal(5, date: day);
    final progress = await store.increment(amount: 20, date: day);

    expect(progress.completed, 5);
    expect(progress.remaining, 0);
    expect(progress.isGoalComplete, isTrue);
  });
}
