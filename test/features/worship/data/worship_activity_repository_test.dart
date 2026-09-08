import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_activity.dart';

void main() {
  test('repository stores activities and exposes a daily summary', () async {
    final backend = MemoryWorshipActivityBackend();
    final repository = WorshipActivityRepository(backend);
    final day = DateTime(2026, 9, 6);

    await repository.record(
      WorshipActivity.salah(prayer: 'Fajr', completedAt: day.add(const Duration(hours: 5))),
    );
    await repository.record(
      WorshipActivity.salah(prayer: 'Fajr', completedAt: day.add(const Duration(hours: 6))),
    );
    await repository.record(
      WorshipActivity.quranPages(pages: 2, recordedAt: day),
    );

    final summary = await repository.getDailySummary(day);

    expect(summary.prayersCompleted, 1);
    expect(summary.quranPages, 2);
  });

  test('recording the same activity id is idempotent', () async {
    final backend = MemoryWorshipActivityBackend();
    final repository = WorshipActivityRepository(backend);
    final activity = WorshipActivity.salah(
      prayer: 'Maghrib',
      completedAt: DateTime(2026, 9, 6, 18),
    );

    await repository.record(activity);
    await repository.record(activity);

    expect((await repository.getAll()).length, 1);
    expect(await repository.isSalahCompleted('Maghrib', DateTime(2026, 9, 6)), isTrue);
  });

  test('daily dhikr snapshot replaces the previous value for a category', () async {
    final backend = MemoryWorshipActivityBackend();
    final repository = WorshipActivityRepository(backend);
    final day = DateTime(2026, 9, 6);

    await repository.upsertDailyDhikr(
      category: 'Morning Azkar',
      completed: 7,
      goal: 33,
      date: day,
    );
    await repository.upsertDailyDhikr(
      category: 'Morning Azkar',
      completed: 12,
      goal: 33,
      date: day,
    );

    final activities = await repository.getAll();
    final summary = await repository.getDailySummary(day);

    expect(activities.where((a) => a.type == WorshipActivityType.dhikr).length, 1);
    expect(summary.dhikrCount, 12);
    expect(summary.dhikrGoal, 33);
  });

  test('daily dhikr snapshots aggregate across categories without accumulating updates', () async {
    final backend = MemoryWorshipActivityBackend();
    final repository = WorshipActivityRepository(backend);
    final day = DateTime(2026, 9, 6);

    await repository.upsertDailyDhikr(
      category: 'Morning Azkar',
      completed: 10,
      goal: 33,
      date: day,
    );
    await repository.upsertDailyDhikr(
      category: 'Evening Azkar',
      completed: 8,
      goal: 33,
      date: day,
    );
    await repository.upsertDailyDhikr(
      category: 'Morning Azkar',
      completed: 15,
      goal: 33,
      date: day,
    );

    final summary = await repository.getDailySummary(day);

    expect(summary.dhikrCount, 23);
    expect(summary.dhikrGoal, 66);
  });

  test('ranged analytics includes every calendar day in the requested range', () async {
    final backend = MemoryWorshipActivityBackend();
    final repository = WorshipActivityRepository(backend);
    final start = DateTime(2026, 9, 1);
    final end = DateTime(2026, 9, 3);

    await repository.record(
      WorshipActivity.salah(prayer: 'Fajr', completedAt: DateTime(2026, 9, 1, 5)),
    );
    await repository.record(
      WorshipActivity.salah(prayer: 'Dhuhr', completedAt: DateTime(2026, 9, 2, 13)),
    );
    await repository.record(
      WorshipActivity.quranPages(pages: 4, recordedAt: DateTime(2026, 9, 3)),
    );

    final summaries = await repository.getDailySummaries(start: start, end: end);
    final analytics = await repository.getAnalytics(start: start, end: end);

    expect(summaries.length, 3);
    expect(summaries.first.prayersCompleted, 1);
    expect(summaries.last.quranPages, 4);
    expect(analytics.days, 3);
    expect(analytics.activeDays, 3);
    expect(analytics.prayerCompletions, 2);
    expect(analytics.prayerCompletionRate, closeTo(2 / 15, 0.0001));
    expect(analytics.quranPages, 4);
    expect(analytics.averageQuranPages, closeTo(4 / 3, 0.0001));
  });

  test('ranged analytics rejects an inverted date range', () async {
    final repository = WorshipActivityRepository(MemoryWorshipActivityBackend());

    expect(
      () => repository.getAnalytics(
        start: DateTime(2026, 9, 3),
        end: DateTime(2026, 9, 1),
      ),
      throwsArgumentError,
    );
  });
}
