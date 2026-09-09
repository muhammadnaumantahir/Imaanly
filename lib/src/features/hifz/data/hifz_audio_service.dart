import 'package:just_audio/just_audio.dart';

enum HifzReciter {
  abdulBasetMujawwad(
    'AbdulBaset AbdulSamad — Mujawwad',
    'AbdulBaset/Mujawwad',
  ),
  alafasy(
    'Mishary Rashid al-Afasy',
    'Alafasy',
  );

  const HifzReciter(this.label, this.pathPrefix);

  final String label;
  final String pathPrefix;
}

/// Resolves and plays a single ayah recitation for Hifz review.
///
/// The default source uses Quran Foundation's documented verse-audio URL
/// shape. Keeping URL construction here makes the review UI independent from
/// the audio provider and makes reciter selection easy to extend later.
class HifzAudioSource {
  const HifzAudioSource._();

  static String forAyah({
    required int surahId,
    required int ayahNumber,
    HifzReciter reciter = HifzReciter.abdulBasetMujawwad,
  }) {
    if (surahId < 1 || surahId > 114) {
      throw ArgumentError.value(surahId, 'surahId', 'must be between 1 and 114');
    }
    if (ayahNumber < 1 || ayahNumber > 286) {
      throw ArgumentError.value(ayahNumber, 'ayahNumber', 'must be between 1 and 286');
    }

    final surah = surahId.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return 'https://verses.quran.foundation/${reciter.pathPrefix}/mp3/$surah$ayah.mp3';
  }
}

class HifzAudioService {
  HifzAudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  bool get playing => _player.playing;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> playAyah({
    required int surahId,
    required int ayahNumber,
    HifzReciter reciter = HifzReciter.abdulBasetMujawwad,
  }) async {
    final url = HifzAudioSource.forAyah(
      surahId: surahId,
      ayahNumber: ayahNumber,
      reciter: reciter,
    );

    // HTML audio requires an explicit cross-origin mode when the source is
    // hosted on another origin. just_audio ignores this setting on platforms
    // where it does not apply, while the web implementation uses it for CORS.
    await _player.setWebCrossOrigin(WebCrossOrigin.anonymous);
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> replay() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> setSpeed(double speed) {
    if (speed < 0.5 || speed > 2.0) {
      throw ArgumentError.value(speed, 'speed', 'must be between 0.5 and 2.0');
    }
    return _player.setSpeed(speed);
  }

  Future<void> dispose() => _player.dispose();
}
