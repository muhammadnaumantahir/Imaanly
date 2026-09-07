import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/hifz.dart';
import 'hifz_bloc.dart';

/// Interactive review session for a memorized ayah range.
/// The session is intentionally text-light: the user self-tests from memory,
/// then records whether each ayah was recalled correctly.
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

  @override
  void initState() {
    super.initState();
    _totalAyahs = (widget.progress.ayahEnd - widget.progress.ayahStart + 1).clamp(1, 1000);
    _startedAt = DateTime.now();
  }

  int get _currentAyah => widget.progress.ayahStart + _currentIndex;

  void _mark(bool correct) {
    if (_finished) return;
    setState(() {
      if (correct) {
        _correct++;
      } else {
        _mistakes++;
      }
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
    final updated = HifzProgress(
      surahId: widget.progress.surahId,
      ayahStart: widget.progress.ayahStart,
      ayahEnd: widget.progress.ayahEnd,
      totalAyahs: widget.progress.totalAyahs,
      lastReviewed: DateTime.now(),
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
      date: DateTime.now(),
      durationSeconds: duration,
      mistakes: _mistakes,
      hints: _hints,
      type: HifzSessionType.review,
    );

    final bloc = context.read<HifzBloc>();
    bloc.add(SaveProgress(updated));
    bloc.add(RecordSession(session));

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

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _totalAyahs;
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
              const Icon(Icons.psychology_outlined, size: 72),
              const SizedBox(height: 20),
              Text(
                'Recite this ayah from memory',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Self-test before revealing the Mushaf. Record the result honestly to improve your review schedule.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
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
