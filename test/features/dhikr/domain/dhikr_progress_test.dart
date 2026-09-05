import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/features/dhikr/domain/dhikr_progress.dart';

void main() {
  group('DhikrProgress', () {
    test('increments today's progress without exceeding the goal', () {
      final progress = DhikrProgress(goal: 33, completed: 32);

      final next = progress.increment(3);

      expect(next.completed, 33);
      expect(next.goal, 33);
      expect(next.isGoalComplete, isTrue);
    });

    test('calculates remaining count and completion percentage', () {
      const progress = DhikrProgress(goal: 100, completed: 25);

      expect(progress.remaining, 75);
      expect(progress.completion, 0.25);
    });

    test('resets progress for a new day', () {
      const progress = DhikrProgress(goal: 100, completed: 80);

      final next = progress.forDate(DateTime(2026, 9, 5));

      expect(next.completed, 0);
      expect(next.goal, 100);
      expect(next.dateKey, '2026-09-05');
    });

    test('keeps the same progress when the date is unchanged', () {
      const progress = DhikrProgress(
        goal: 100,
        completed: 40,
        dateKey: '2026-09-05',
      );

      final next = progress.forDate(DateTime(2026, 9, 5));

      expect(next.completed, 40);
      expect(next.dateKey, '2026-09-05');
    });
  });

  group('DhikrStreakCalculator', () {
    test('counts consecutive completed days ending today', () {
      final streak = DhikrStreakCalculator.calculate(
        completedDates: {
          '2026-09-03',
          '2026-09-04',
          '2026-09-05',
          '2026-08-30',
        },
        today: DateTime(2026, 9, 5),
      );

      expect(streak, 3);
    });

    test('returns zero when today is not completed', () {
      final streak = DhikrStreakCalculator.calculate(
        completedDates: {'2026-09-04'},
        today: DateTime(2026, 9, 5),
      );

      expect(streak, 0);
    });
  });
}
