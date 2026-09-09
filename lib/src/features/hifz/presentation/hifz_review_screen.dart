import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../quran/domain/entities/entities.dart';
import '../../quran/domain/repositories/quran_repository.dart';
import '../data/hifz_audio_service.dart';
import '../domain/entities/hifz.dart';
import 'hifz_bloc.dart';

class HifzReviewScreen extends StatefulWidget {
  const HifzReviewScreen({super.key, required this.progress});
  final HifzProgress progress;

  @override
  State<HifzReviewScreen> createState() => _HifzReviewScreenState();
}

class _HifzReviewScreenState extends State<HifzReviewScreen> {
  late final int _totalAyahs;
  late final DateTime _startedAt;
  late final HifzAudioService _audio;
  int _currentIndex = 0;
  int _correct = 0;
  int _mistakes = 0;
  int _hints = 0;
  double _speed = 1.0;
  HifzReciter _reciter = HifzReciter.abdulBasetMujawwad;
  bool _finished = false;
  bool _revealed = false;
  bool _loadingText = true;
  bool _loadingAudio = false;
  String? _textError;
  String? _audioError;
  final Map<int, Ayah> _ayahs = {};

  int get _currentAyah => widget.progress.ayahStart + _currentIndex;

  @override
  void initState() {
    super.initState();
    _totalAyahs = (widget.progress.ayahEnd - widget.progress.ayahStart + 1).clamp(1, 1000).toInt();
    _startedAt = DateTime.now();
    _audio = HifzAudioService();
    _loadQuranText();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _loadQuranText() async {
    final result = await getIt<QuranRepository>().getAyahsBySurah(widget.progress.surahId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() { _loadingText = false; _textError = failure.message; }),
      (ayahs) => setState(() {
        for (final ayah in ayahs) {
          if (ayah.ayahNumber >= widget.progress.ayahStart && ayah.ayahNumber <= widget.progress.ayahEnd) _ayahs[ayah.ayahNumber] = ayah;
        }
        _loadingText = false;
        _textError = null;
      }),
    );
  }

  Future<void> _toggleAudio() async {
    if (_loadingText || _finished) return;
    setState(() { _loadingAudio = true; _audioError = null; });
    try {
      await _audio.playAyah(surahId: widget.progress.surahId, ayahNumber: _currentAyah, reciter: _reciter);
      await _audio.setSpeed(_speed);
    } catch (_) {
      if (mounted) setState(() => _audioError = 'Audio could not be played. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loadingAudio = false);
    }
  }

  Future<void> _pauseAudio() async {
    await _audio.pause();
  }

  Future<void> _replayAudio() async {
    if (_loadingText || _finished) return;
    try {
      await _audio.replay();
      await _audio.setSpeed(_speed);
    } catch (_) {
      await _toggleAudio();
    }
  }

  Future<void> _changeSpeed(double speed) async {
    setState(() => _speed = speed);
    try {
      await _audio.setSpeed(speed);
    } catch (_) {
      // Speed is a player preference; an unavailable player should not break review.
    }
  }

  Future<void> _changeReciter(HifzReciter reciter) async {
    if (_reciter == reciter) return;
    setState(() { _reciter = reciter; _audioError = null; });
    if (_audio.playing) {
      await _audio.stop();
      if (mounted) await _toggleAudio();
    }
  }

  void _mark(bool correct) {
    if (_finished) return;
    _audio.stop();
    setState(() {
      if (correct) { _correct++; } else { _mistakes++; }
      _revealed = false;
      _audioError = null;
      if (_currentIndex + 1 >= _totalAyahs) { _finished = true; } else { _currentIndex++; }
    });
    if (_finished) _finish();
  }

  void _hint() {
    if (_finished) return;
    setState(() => _hints++);
  }

  Future<void> _finish() async {
    await _audio.stop();
    if (!mounted) return;
    final accuracy = _correct / _totalAyahs;
    final mastery = accuracy >= .85 ? HifzMasteryLevel.mastered : accuracy >= .60 ? HifzMasteryLevel.confident : accuracy >= .30 ? HifzMasteryLevel.familiar : HifzMasteryLevel.learning;
    final reviewedAt = DateTime.now();
    final updated = HifzProgress(surahId: widget.progress.surahId, ayahStart: widget.progress.ayahStart, ayahEnd: widget.progress.ayahEnd, totalAyahs: widget.progress.totalAyahs, lastReviewed: reviewedAt, mastery: mastery, reviewCount: widget.progress.reviewCount + _totalAyahs, correctCount: widget.progress.correctCount + _correct, mistakeCount: widget.progress.mistakeCount + _mistakes);
    final session = HifzSession(id: DateTime.now().microsecondsSinceEpoch, surahId: widget.progress.surahId, ayahStart: widget.progress.ayahStart, ayahEnd: widget.progress.ayahEnd, date: reviewedAt, durationSeconds: DateTime.now().difference(_startedAt).inSeconds.clamp(1, 86400).toInt(), mistakes: _mistakes, hints: _hints, type: HifzSessionType.review);
    context.read<HifzBloc>().add(CompleteReview(progress: updated, session: session));
    await showDialog<void>(context: context, barrierDismissible: false, builder: (context) => AlertDialog(title: const Text('Review complete'), content: Text('$_correct of $_totalAyahs ayahs recalled correctly.\n\nAccuracy: ${(accuracy * 100).round()}%\nMastery: ${_masteryLabel(mastery)}'), actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done'))]));
    if (mounted) Navigator.of(context).pop();
  }

  String _masteryLabel(HifzMasteryLevel level) => switch (level) {
    HifzMasteryLevel.notStarted => 'Not started',
    HifzMasteryLevel.learning => 'Learning',
    HifzMasteryLevel.familiar => 'Familiar',
    HifzMasteryLevel.confident => 'Confident',
    HifzMasteryLevel.mastered => 'Mastered',
  };

  @override
  Widget build(BuildContext context) {
    final ayah = _ayahs[_currentAyah];
    return Scaffold(
      appBar: AppBar(title: Text('Surah ${widget.progress.surahId} review')),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        LinearProgressIndicator(value: (_currentIndex + 1) / _totalAyahs, minHeight: 7),
        const SizedBox(height: 12),
        Text('Ayah $_currentAyah of ${widget.progress.ayahEnd}'),
        const Spacer(),
        const Icon(Icons.psychology_outlined, size: 64),
        const SizedBox(height: 16),
        Text('Recite this ayah from memory', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (_loadingText) const CircularProgressIndicator()
        else if (_textError != null) Text('Quran text unavailable: $_textError', textAlign: TextAlign.center)
        else if (_revealed && ayah != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(ayah.textUthmani, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 2))))
        else if (_hints > 0 && ayah != null) Text('Hint: ${ayah.textUthmani.trim().split(RegExp(r'\s+')).take(5).join(' ')} …', textDirection: TextDirection.rtl, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        StreamBuilder<bool>(stream: _audio.playingStream, initialData: false, builder: (context, snapshot) {
          final playing = snapshot.data ?? false;
          return Column(children: [
            StreamBuilder<Duration>(stream: _audio.positionStream, initialData: Duration.zero, builder: (context, positionSnapshot) {
              return StreamBuilder<Duration?>(stream: _audio.durationStream, initialData: null, builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data;
                final position = positionSnapshot.data ?? Duration.zero;
                final max = duration == null || duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
                final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
                return LinearProgressIndicator(value: duration == null ? null : value / max, minHeight: 4);
              });
            }),
            const SizedBox(height: 8),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(onPressed: _loadingAudio ? null : (playing ? _pauseAudio : _toggleAudio), icon: _loadingAudio ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(playing ? Icons.pause_rounded : Icons.volume_up_rounded), label: Text(playing ? 'Pause' : 'Play audio')),
              OutlinedButton.icon(onPressed: _loadingAudio || !playing ? _replayAudio : _replayAudio, icon: const Icon(Icons.replay_rounded), label: const Text('Replay')),
              DropdownButton<double>(value: _speed, underline: const SizedBox.shrink(), items: const [0.75, 1.0, 1.25, 1.5].map((speed) => DropdownMenuItem(value: speed, child: Text('${speed}x'))).toList(), onChanged: (value) { if (value != null) _changeSpeed(value); }),
              DropdownButton<HifzReciter>(value: _reciter, underline: const SizedBox.shrink(), items: HifzReciter.values.map((reciter) => DropdownMenuItem(value: reciter, child: Text(reciter.label, overflow: TextOverflow.ellipsis))).toList(), onChanged: _loadingAudio ? null : (value) { if (value != null) _changeReciter(value); }),
            ]),
          ]);
        }),
        if (_audioError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_audioError!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
          OutlinedButton.icon(onPressed: _loadingText ? null : () => setState(() => _revealed = !_revealed), icon: Icon(_revealed ? Icons.visibility_off_outlined : Icons.menu_book_outlined), label: Text(_revealed ? 'Hide ayah' : 'Reveal Mushaf')),
          OutlinedButton.icon(onPressed: _hint, icon: const Icon(Icons.lightbulb_outline), label: Text(_hints == 0 ? 'Need a hint' : 'Hint used ($_hints)')),
        ]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: () => _mark(false), icon: const Icon(Icons.close_rounded), label: const Text('Mistake'))), const SizedBox(width: 12), Expanded(child: FilledButton.icon(onPressed: () => _mark(true), icon: const Icon(Icons.check_rounded), label: const Text('Correct')))]),
        const SizedBox(height: 12),
        Text('Correct: $_correct  •  Mistakes: $_mistakes'),
        const Spacer(),
      ]))),
    );
  }
}
