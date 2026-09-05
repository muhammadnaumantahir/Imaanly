import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/src/features/qibla/domain/qibla_calculator.dart';

void main() {
  group('QiblaCalculator', () {
    test('calculates a positive great-circle distance to the Kaaba', () {
      final distance = QiblaCalculator.distanceToKaaba(
        31.5204,
        74.3587,
      );

      expect(distance, greaterThan(900));
      expect(distance, lessThan(1_100));
    });

    test('normalizes compass headings to the 0-360 range', () {
      expect(QiblaCalculator.normalizeDegrees(-10), 350);
      expect(QiblaCalculator.normalizeDegrees(370), 10);
      expect(QiblaCalculator.normalizeDegrees(720), 0);
    });

    test('returns the shortest signed turn from heading to qibla', () {
      expect(QiblaCalculator.shortestSignedDifference(350, 10), 20);
      expect(QiblaCalculator.shortestSignedDifference(10, 350), -20);
    });
  });
}
