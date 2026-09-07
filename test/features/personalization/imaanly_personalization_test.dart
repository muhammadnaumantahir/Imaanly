import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:imaanly/features/personalization/data/imaanly_personalization_repository.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';

void main() {
  test('uses safe local defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = ImaanlyPersonalizationRepository(prefs);

    expect(repository.load().themeMode, 'system');
    expect(repository.load().homeShortcuts, contains('quran'));
  });

  test('round-trips personalization locally', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = ImaanlyPersonalizationRepository(prefs);
    final value = const ImaanlyPersonalization(
      homeShortcuts: ['quran', 'calendar'],
      themeMode: 'dark',
      quranScript: 'indopak',
      quranShowTranslation: false,
      dhikrDailyGoal: 100,
      dashboardCompact: true,
    );

    await repository.save(value);
    final loaded = repository.load();

    expect(loaded.toJson(), value.toJson());
  });

  test('reset restores defaults and import validates input', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = ImaanlyPersonalizationRepository(prefs);

    expect(await repository.importJson('{"themeMode":"dark"}'), isTrue);
    expect(repository.load().themeMode, 'dark');
    expect(await repository.importJson('{invalid'), isFalse);

    await repository.reset();
    expect(repository.load().themeMode, 'system');
  });
}
