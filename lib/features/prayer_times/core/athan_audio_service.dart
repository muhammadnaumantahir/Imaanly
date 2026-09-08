import 'package:just_audio/just_audio.dart';

enum AthanAudio {
  dohaFajr(
    'أذان الدوحة — الفجر',
    'https://archive.org/download/adhan.recordings.from.doha.qatar/Adhan_Doha_Qatar_01_Fajr_Adhan.mp3',
  ),
  dohaDhuhr(
    'أذان الدوحة — الظهر',
    'https://archive.org/download/adhan.recordings.from.doha.qatar/Adhan_Doha_Qatar_02_Dhuhr_Adhan.mp3',
  ),
  dohaAsr(
    'أذان الدوحة — العصر',
    'https://archive.org/download/adhan.recordings.from.doha.qatar/Adhan_Doha_Qatar_03_Asr_Adhan.mp3',
  ),
  dohaMaghrib(
    'أذان الدوحة — المغرب',
    'https://archive.org/download/adhan.recordings.from.doha.qatar/Adhan_Doha_Qatar_04_Maghrib_Adhan.mp3',
  ),
  dohaIsha(
    'أذان الدوحة — العشاء',
    'https://archive.org/download/adhan.recordings.from.doha.qatar/Adhan_Doha_Qatar_05_Isha_Adhan.mp3',
  );

  const AthanAudio(this.label, this.url);

  final String label;
  final String url;
}

/// Plays a real Athan recording on supported Flutter platforms.
///
/// The recordings are remote HTTPS MP3 files so the same implementation can
/// be used on Android and Chrome. Web playback must be initiated by a user
/// gesture because browsers may block autoplay.
class AthanAudioService {
  AthanAudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Stream<bool> get playingStream => _player.playingStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Future<void> play(AthanAudio athan) async {
    if (_player.playing) {
      await _player.stop();
    }
    await _player.setUrl(athan.url);
    await _player.play();
  }

  Future<void> stop() => _player.stop();

  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();
}
