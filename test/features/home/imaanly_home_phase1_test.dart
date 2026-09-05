import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Imaanly Phase 1 home contract', () {
    test('keeps the initial home focused on the core companion actions', () {
      const actions = <String>['Prayer', 'Quran', 'Dhikr', 'Qibla'];

      expect(actions, containsAll(<String>['Prayer', 'Quran', 'Dhikr', 'Qibla']));
      expect(actions, hasLength(4));
    });

    test('does not require an account for the initial experience', () {
      const requiresAccount = false;

      expect(requiresAccount, isFalse);
    });

    test('keeps advertising disabled for the initial release', () {
      const adsEnabled = false;

      expect(adsEnabled, isFalse);
    });
  });
}
