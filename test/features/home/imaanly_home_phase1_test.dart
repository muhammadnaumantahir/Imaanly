import 'package:al_furkan/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Imaanly Phase 1 home contract', () {
    test('keeps the initial home focused on the core companion actions', () {
      const actions = <String>['Prayer', 'Quran', 'Dhikr', 'Qibla'];

      expect(actions, containsAll(<String>['Prayer', 'Quran', 'Dhikr', 'Qibla']));
      expect(actions, hasLength(4));
    });

    test('uses a softer 16px card radius for the Imaanly visual system', () {
      final shape = AppTheme.lightTheme().cardTheme.shape as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;

      expect(radius, 16);
    });

    test('keeps advertising disabled for the initial release', () {
      const adsEnabled = false;

      expect(adsEnabled, isFalse);
    });
  });
}
