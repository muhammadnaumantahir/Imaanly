import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../quran/domain/entities/entities.dart';
import '../../quran/domain/repositories/quran_repository.dart';
import '../../core/di/service_locator.dart';
import '../domain/entities/hifz.dart';
import 'hifz_bloc.dart';

/// Interactive Hifz review session backed by the local Quran repository.
///
/// The user first recalls each ayah from memory. The actual Quran text can be
/// revealed after the attempt, while hints expose only a small prefix.
class HifzReviewScreen extends StatefulWidget {
  final HifzProgress progress;

  const HifzReviewScreen({super.key, required this.progress});

  @override
  State<HifzReviewScreen> createState() => _HifzReviewScreenState();
}

class _HifzReviewScreenState extends State<HifzReviewScreen> {
  late final int _totalAyahs;
  int _currentIndex = 0;
  int _correct = 0;
  int _mistakes = 0;
  int _hints = 0;
  late final DateTime _startedAt;
  bool _finished = false;
  bool _revealed = false;
  bool _loadingText = true;
  String? _textError;
  final Map<int, Ayah> _ayahs = {};

  @override
  void initState() {
    super.initState();
    _totalAyahs =
        (widget.progress.ayahEnd - widget.progress.ayahStart + 1).clamp(1, 1000);
    _startedAt = DateTime.now();
    _loadQuranText();
  }

  int get _currentAyah => widget.progress.ayahStart + _currentIndex;

  Future<void> _loadQuranText() async {
    final result = await getIt<QuranRepository>().getAyahsBySurah(widget.progress.surahId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingText = false;
        _textError = failure.message;
      }),
      (ayahs) => setState(() {
        for (final ayah in ayahs) {
          if (ayah.ayahNumber >= widget.progress.ayahStart &&
              ayah.ayahNumber <= widget.progress.ayahEnd) {
            _ayahs[ayah.ayahNumber] = ayah;
          }
        }
        _loadingText = false;
        _textError = null;
      }),
    );
  }

  void _mark(bool correct) {
    if (_finished) return;
    setState(() {
      if (correct) {
        _correct++;
      } else {
        _mistakes++;
      }
      _revealed = false;
      if (_currentIndex + 1 >= _totalAyahs) {
        _finished = true;
      } else {
        _currentIndex++;
      }
    });
    if (_finished) _finish();
  }

  void _hint() {
    if (_finished) return;
    setState(() => _hints++);
  }

  Future<void> _finish() async {
    final accuracy = _correct / _totalAyahs;
    final nextMastery = _masteryForAccuracy(accuracy);
    final reviewedAt = DateTime.now();
    final updated = HifzProgress(
      surahId: widget.progress.surahId,
      ayahStart: widget.progress.ayahStart,
      ayahEnd: widget.progress.ayahEnd,
      totalAyahs: widget.progress.totalAyahs,
      lastReviewed: reviewedAt,
      mastery: nextMastery,
      reviewCount: widget.progress.reviewCount + _totalAyahs,
      correctCount: widget.progress.correctCount + _correct,
      mistakeCount: widget.progress.mistakeCount + _mistakes,
    );

    final duration = DateTime.now().difference(_startedAt).inSeconds.clamp(1, 86400);
    final session = HifzSession(
      id: DateTime.now().microsecondsSinceEpoch,
      surahId: widget.progress.surahId,
      ayahStart: widget.progress.ayahStart,
      ayahEnd: widget.progress.ayahEnd,
      date: reviewedAt,
      durationSeconds: duration,
      mistakes: _mistakes,
      hints: _hints,
      type: HifzSessionType.review,
    );

    context.read<HifzBloc>().add(CompleteReview(progress: updated, session: session));

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Review complete'),
        content: Text(
          '$_correct of $_totalAyahs ayahs recalled correctly.\n\n'
          'Accuracy: ${(accuracy * 100).round()}%\n'
          'Mastery: ${_masteryLabel(nextMastery)}',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  HifzMasteryLevel _masteryForAccuracy(double accuracy) {
    if (accuracy >= .85) return HifzMasteryLevel.mastered;
    if (accuracy >= .60) return HifzMasteryLevel.confident;
    if (accuracy >= .30) return HifzMasteryLevel.familiar;
    return HifzMasteryLevel.learning;
  }

  String _masteryLabel(HifzMasteryLevel level) => switch (level) {
        HifzMasteryLevel.notStarted => 'Not started',
        HifzMasteryLevel.learning => 'Learning',
        HifzMasteryLevel.familiar => 'Familiar',
        HifzMasteryLevel.confident => 'Confident',
        HifzMasteryLevel.mastered => 'Mastered',
      };

  String _hintText(Ayah? ayah) {
    if (ayah == null) return 'Quran text is still loading.';
    final words = ayah.textUthmani.trim().split(RegExp(r'\s+'));
    return words.take(5).join(' ') + (words.length > 5 ? ' …' : '');
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _totalAyahs;
    final ayah = _ayahs[_currentAyah];
    return Scaffold(
      appBar: AppBar(title: Text('Surah ${widget.progress.surahId} review')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: progress, minHeight: 7),
              const SizedBox(height: 12),
              Text('Ayah $_currentAyah of ${widget.progress.ayahEnd}', textAlign: TextAlign.center),
              const Spacer(),
              const Icon(Icons.psychology_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Recite this ayah from memory',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (_loadingText)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_textError != null)
                Text('Quran text unavailable: $_textError', textAlign: TextAlign.center)
              else if (_revealed && ayah != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      ayah.textUthmani,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 2.0),
                    ),
                  ),
                )
              else if (_hints > 0)
                Text(
                  'Hint: ${_hintText(ayah)}',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadingText ? null : () => setState(() => _revealed = !_revealed),
                icon: Icon(_revealed ? Icons.visibility_off_outlined : Icons.menu_book_outlined),
                label: Text(_revealed ? 'Hide ayah' : 'Reveal Mushaf'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _hint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(_hints == 0 ? 'Need a hint' : 'Hint used ($_hints)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _mark(false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Mistake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _mark(true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Correct'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Correct: $_correct  •  Mistakes: $_mistakes', textAlign: TextAlign.center),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
