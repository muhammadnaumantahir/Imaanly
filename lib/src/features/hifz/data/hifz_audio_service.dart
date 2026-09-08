import 'package:just_audio/just_audio.dart';

/// Resolves and plays a single ayah recitation for Hifz review.
///
/// The default source uses the documented Quran Foundation verse-audio
/// resource shape. Keeping URL construction here makes the review UI
/// independent from the audio provider and makes it easy to replace later.
class HifzAudioSource {
  const HifzAudioSource._();

  static String forAyah({required int surahId, required int ayahNumber}) {
    if (surahId < 1 || surahId > 114) {
      throw ArgumentError.value(surahId, 'surahId', 'must be between 1 and 114');
    }
    if (ayahNumber < 1 || ayahNumber > 286) {
      throw ArgumentError.value(ayahNumber, 'ayahNumber', 'must be between 1 and 286');
    }

    final surah = surahId.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return 'https://verses.quran.foundation/AbdulBaset/Mujawwad/mp3/$surah$ayah.mp3';
  }
}

class HifzAudioService {
  HifzAudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Stream<bool> get playingStream => _player.playingStream;

  Future<void> playAyah({required int surahId, required int ayahNumber}) async {
    final url = HifzAudioSource.forAyah(
      surahId: surahId,
      ayahNumber: ayahNumber,
    );
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
