import 'package:flutter_test/flutter_test.dart';

import 'package:imaanly/src/features/hifz/domain/entities/hifz.dart';

HifzMasteryLevel masteryForAccuracy(double accuracy) {
  if (accuracy >= .85) return HifzMasteryLevel.mastered;
  if (accuracy >= .60) return HifzMasteryLevel.confident;
  if (accuracy >= .30) return HifzMasteryLevel.familiar;
  return HifzMasteryLevel.learning;
}

void main() {
  group('Hifz review mastery thresholds', () {
    test('85% or higher is mastered', () {
      expect(masteryForAccuracy(.85), HifzMasteryLevel.mastered);
      expect(masteryForAccuracy(1), HifzMasteryLevel.mastered);
    });

    test('60% to below 85% is confident', () {
      expect(masteryForAccuracy(.60), HifzMasteryLevel.confident);
      expect(masteryForAccuracy(.84), HifzMasteryLevel.confident);
    });

    test('30% to below 60% is familiar', () {
      expect(masteryForAccuracy(.30), HifzMasteryLevel.familiar);
      expect(masteryForAccuracy(.59), HifzMasteryLevel.familiar);
    });

    test('below 30% is learning', () {
      expect(masteryForAccuracy(0), HifzMasteryLevel.learning);
      expect(masteryForAccuracy(.29), HifzMasteryLevel.learning);
    });
  });
}
