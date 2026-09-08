import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/src/features/hifz/data/hifz_audio_service.dart';

void main() {
  group('HifzAudioSource', () {
    test('builds documented Quran Foundation verse URL', () {
      expect(
        HifzAudioSource.forAyah(surahId: 1, ayahNumber: 1),
        'https://verses.quran.foundation/AbdulBaset/Mujawwad/mp3/001001.mp3',
      );
      expect(
        HifzAudioSource.forAyah(surahId: 2, ayahNumber: 255),
        'https://verses.quran.foundation/AbdulBaset/Mujawwad/mp3/002255.mp3',
      );
    });

    test('rejects invalid surah and ayah ranges', () {
      expect(() => HifzAudioSource.forAyah(surahId: 0, ayahNumber: 1), throwsArgumentError);
      expect(() => HifzAudioSource.forAyah(surahId: 115, ayahNumber: 1), throwsArgumentError);
      expect(() => HifzAudioSource.forAyah(surahId: 1, ayahNumber: 0), throwsArgumentError);
      expect(() => HifzAudioSource.forAyah(surahId: 1, ayahNumber: 287), throwsArgumentError);
    });
  });
}
