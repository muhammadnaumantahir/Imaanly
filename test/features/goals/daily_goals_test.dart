import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/goals/data/daily_goals_repository.dart';
import 'package:imaanly/features/goals/domain/daily_goals.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('daily goals round-trip through json', () {
    const original = DailyGoals(
      quranPages: 10,
      quranAyahs: 100,
      dhikr: 500,
      salah: 5,
    );

    final restored = DailyGoals.fromJson(original.toJson());

    expect(restored.quranPages, 10);
    expect(restored.quranAyahs, 100);
    expect(restored.dhikr, 500);
    expect(restored.salah, 5);
  });

  test('invalid or negative values are safely bounded', () {
    final goals = DailyGoals.fromJson({
      'quranPages': -10,
      'quranAyahs': 200000,
      'dhikr': 'not a number',
      'salah': -2,
    });

    expect(goals.quranPages, 0);
    expect(goals.quranAyahs, 100000);
    expect(goals.dhikr, 33);
    expect(goals.salah, 0);
  });

  test('copyWith changes only requested targets', () {
    const original = DailyGoals();
    final updated = original.copyWith(dhikr: 100);

    expect(updated.dhikr, 100);
    expect(updated.quranPages, original.quranPages);
    expect(updated.quranAyahs, original.quranAyahs);
    expect(updated.salah, original.salah);
  });

  test('personalized Dhikr goal overrides the legacy goal value', () async {
    SharedPreferences.setMockInitialValues({
      'imaanly.daily_goals.v1':
          jsonEncode(const DailyGoals(dhikr: 500).toJson()),
      'imaanly.personalization.v1':
          const ImaanlyPersonalization(dhikrDailyGoal: 100).encode(),
    });
    final preferences = await SharedPreferences.getInstance();

    final goals = DailyGoalsRepository(preferences).load();

    expect(goals.dhikr, 100);
    expect(goals.quranPages, 5);
    expect(goals.salah, 5);
  });
}
