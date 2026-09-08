import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/prayer_times/core/athan_audio_service.dart';

void main() {
  test('Athan catalog contains real HTTPS MP3 sources', () {
    expect(AthanAudio.values, isNotEmpty);
    for (final athan in AthanAudio.values) {
      expect(athan.url, startsWith('https://'));
      expect(athan.url, endsWith('.mp3'));
      expect(athan.label, isNotEmpty);
    }
  });

  test('Athan catalog provides separate prayer recordings', () {
    expect(AthanAudio.values.map((item) => item.url).toSet().length,
        AthanAudio.values.length);
    expect(AthanAudio.dohaFajr.label, contains('الفجر'));
    expect(AthanAudio.dohaMaghrib.label, contains('المغرب'));
  });
}
