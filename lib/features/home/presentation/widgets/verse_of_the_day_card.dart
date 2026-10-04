import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../src/theme/app_widgets.dart';

/// A calm daily reminder: one ayah (text taken from the app's own Quran data),
/// rotating once per day through a short list of well-known verses.
class VerseOfTheDayCard extends StatelessWidget {
  const VerseOfTheDayCard({super.key, required this.now, this.onOpenQuran});

  final DateTime now;
  final VoidCallback? onOpenQuran;

  /// (surah, ayah) pairs.
  static const List<(int, int)> _verses = [
    (2, 255),
    (2, 286),
    (94, 5),
    (94, 6),
    (13, 28),
    (2, 152),
    (65, 3),
    (39, 53),
    (20, 114),
    (2, 186),
    (49, 13),
    (55, 13),
    (3, 173),
    (14, 7),
    (24, 35),
    (2, 153),
    (40, 60),
    (112, 1),
  ];

  (int, int) get _today {
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _verses[(now.year * 366 + dayOfYear) % _verses.length];
  }

  String _arabic(int surah, int ayah) => getVerse(surah, ayah, verseEndSymbol: false);

  String _reference(int surah, int ayah) =>
      'Surah ${getSurahNameEnglish(surah)} \u2022 $surah:$ayah';

  void _openSheet(BuildContext context) {
    final (surah, ayah) = _today;
    final text = _arabic(surah, ayah);
    final ref = _reference(surah, ayah);
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'me_quran_volt_newmet',
                      fontFamilyFallback: ['Cairo-Regular'],
                      fontSize: 28,
                      height: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ref,
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$text\n$ref'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ayah copied')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Open Quran'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onOpenQuran?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (surah, ayah) = _today;
    return SoftCard(
      onTap: () => _openSheet(context),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFFC9A24B)),
              const SizedBox(width: 8),
              Text(
                'VERSE OF THE DAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Icon(Icons.open_in_full_rounded, size: 16, color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _arabic(surah, ayah),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'me_quran_volt_newmet',
                fontFamilyFallback: ['Cairo-Regular'],
                fontSize: 24,
                height: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _reference(surah, ayah),
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
