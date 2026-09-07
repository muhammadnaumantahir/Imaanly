import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/personalization/data/imaanly_personalization_repository.dart';
import 'package:imaanly/features/personalization/domain/imaanly_personalization.dart';
import 'package:imaanly/features/personalization/presentation/personalization_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads persisted personalization and updates it reactively', () async {
    SharedPreferences.setMockInitialValues({
      'imaanly.personalization.v1': const ImaanlyPersonalization(dhikrDailyGoal: 99).encode(),
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = PersonalizationCubit(ImaanlyPersonalizationRepository(prefs));

    expect(cubit.state.dhikrDailyGoal, 99);
    await cubit.update(cubit.state.copyWith(dashboardCompact: true));

    expect(cubit.state.dashboardCompact, isTrue);
    expect(ImaanlyPersonalizationRepository(prefs).load().dashboardCompact, isTrue);
    await cubit.close();
  });

  test('reset restores defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = PersonalizationCubit(ImaanlyPersonalizationRepository(prefs));
    await cubit.update(const ImaanlyPersonalization(quranScript: 'indopak'));
    await cubit.reset();

    expect(cubit.state.quranScript, 'uthmanic');
    expect(cubit.state.dhikrDailyGoal, 33);
    await cubit.close();
  });
}
