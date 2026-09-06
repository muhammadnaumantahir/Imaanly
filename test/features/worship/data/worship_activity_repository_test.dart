import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/worship/data/worship_activity_repository.dart';
import 'package:al_furkan/features/worship/domain/worship_activity.dart';

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
}
