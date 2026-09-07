import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/quran_resources/meta/meta_data_surah.dart';
import '../domain/entities/hifz.dart';
import 'hifz_bloc.dart';
import 'hifz_review_screen.dart';

/// Starts a new memorization range and immediately makes it available for review.
class HifzNewMemorizationScreen extends StatefulWidget {
  const HifzNewMemorizationScreen({super.key});

  @override
  State<HifzNewMemorizationScreen> createState() => _HifzNewMemorizationScreenState();
}

class _HifzNewMemorizationScreenState extends State<HifzNewMemorizationScreen> {
  int _surahId = 1;
  int _ayahStart = 1;
  int _ayahEnd = 1;

  int get _surahAyahCount => (metaDataSurah['$_surahId']?['vc'] as int?) ?? 1;

  @override
  void initState() {
    super.initState();
    _ayahEnd = _surahAyahCount.clamp(1, 5);
  }

  void _selectSurah(int value) {
    final count = (metaDataSurah['$value']?['vc'] as int?) ?? 1;
    setState(() {
      _surahId = value;
      _ayahStart = 1;
      _ayahEnd = count.clamp(1, 5);
    });
  }

  Future<void> _start() async {
    if (_ayahStart < 1 || _ayahEnd < _ayahStart || _ayahEnd > _surahAyahCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Choose ayahs between 1 and $_surahAyahCount.')),
      );
      return;
    }

    final progress = HifzProgress(
      surahId: _surahId,
      ayahStart: _ayahStart,
      ayahEnd: _ayahEnd,
      totalAyahs: _surahAyahCount,
      lastReviewed: DateTime.fromMillisecondsSinceEpoch(0),
      mastery: HifzMasteryLevel.notStarted,
      reviewCount: 0,
      correctCount: 0,
      mistakeCount: 0,
    );

    context.read<HifzBloc>().add(SaveProgress(progress));
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HifzReviewScreen(progress: progress)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Memorization')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Start Hifz', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Choose a Surah and the ayah range you want to memorize. Your range will then appear in Hifz progress and review.'),
          const SizedBox(height: 24),
          DropdownButtonFormField<int>(
            value: _surahId,
            decoration: const InputDecoration(labelText: 'Surah', border: OutlineInputBorder()),
            items: [
              for (var id = 1; id <= 114; id++)
                DropdownMenuItem(value: id, child: Text('Surah $id')),
            ],
            onChanged: (value) { if (value != null) _selectSurah(value); },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _AyahField(label: 'Start ayah', value: _ayahStart, max: _surahAyahCount, onChanged: (v) => setState(() => _ayahStart = v))),
              const SizedBox(width: 12),
              Expanded(child: _AyahField(label: 'End ayah', value: _ayahEnd, max: _surahAyahCount, onChanged: (v) => setState(() => _ayahEnd = v))),
            ],
          ),
          const SizedBox(height: 12),
          Text('Surah $_surahId contains $_surahAyahCount ayahs.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start memorization'),
          ),
        ],
      ),
    );
  }
}

class _AyahField extends StatelessWidget {
  const _AyahField({required this.label, required this.value, required this.max, required this.onChanged});
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, helperText: '1–$max', border: const OutlineInputBorder()),
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}
