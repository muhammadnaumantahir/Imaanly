import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/src/features/hifz/data/hifz_audio_service.dart';

void main() {
  group('HifzAudioSource', () {
    test('builds the default AbdulBaset URL', () {
      expect(
        HifzAudioSource.forAyah(surahId: 1, ayahNumber: 1),
        'https://verses.quran.foundation/AbdulBaset/Mujawwad/mp3/001001.mp3',
      );
    });

    test('builds the Alafasy URL', () {
      expect(
        HifzAudioSource.forAyah(
          surahId: 2,
          ayahNumber: 255,
          reciter: HifzReciter.alafasy,
        ),
        'https://verses.quran.foundation/Alafasy/mp3/002255.mp3',
      );
    });

    test('rejects invalid surah and ayah ranges', () {
      expect(
        () => HifzAudioSource.forAyah(surahId: 0, ayahNumber: 1),
        throwsArgumentError,
      );
      expect(
        () => HifzAudioSource.forAyah(surahId: 114, ayahNumber: 287),
        throwsArgumentError,
      );
    });
  });
}
