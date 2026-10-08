import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:imaanly/features/dhikr/domain/dhikr_progress.dart';
import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/src/screen/azkar/azkar_share_screen.dart';
import 'package:imaanly/src/theme/app_colors.dart';
import 'azkar_category_names.dart';

class AzkarDetailScreen extends StatefulWidget {
  const AzkarDetailScreen({super.key, required this.categoryName, required this.azkarList, required this.primary});
  final String categoryName;
  final List<Map<String, dynamic>> azkarList;
  final Color primary;

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late final PageController _pageController;
  late List<int> _counts;
  int _currentIndex = 0;
  double _fontSize = 26;
  late DhikrProgress _dailyProgress;

  Box get _box => Hive.box('user');
  String get _progressKey => 'dhikr_progress_${widget.categoryName}';
  String get _countsKey => '${_progressKey}_counts';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _counts = widget.azkarList.map((item) => int.tryParse(item['count']?.toString() ?? '') ?? 1).toList();
    _restore();
  }

  void _restore() {
    final today = DateTime.now();
    final saved = _box.get(_progressKey);
    _dailyProgress = saved is Map
        ? DhikrProgress.fromMap(saved).forDate(today)
        : DhikrProgress(goal: 33, completed: 0, dateKey: DhikrProgress.dateKeyFor(today));
    final counts = _box.get(_countsKey);
    if (counts is Map && counts['dateKey']?.toString() == _dailyProgress.dateKey && counts['values'] is Map) {
      final values = counts['values'] as Map;
      for (var i = 0; i < _counts.length; i++) {
        final value = values[i.toString()];
        if (value is num) _counts[i] = value.toInt().clamp(0, _counts[i]);
      }
    }
  }

  void _persist() {
    _box.put(_progressKey, _dailyProgress.toMap());
    _box.put(_countsKey, {
      'dateKey': _dailyProgress.dateKey,
      'values': {for (var i = 0; i < _counts.length; i++) '$i': _counts[i]},
    });
  }

  void _recordTap() {
    _dailyProgress = _dailyProgress.increment();
    _persist();
    unawaited(_syncWorship());
  }

  Future<void> _syncWorship() async {
    try {
      final repository = await WorshipActivityRepository.openLocal();
      await repository.upsertDailyDhikr(category: widget.categoryName, completed: _dailyProgress.completed, goal: _dailyProgress.goal);
    } catch (_) {}
  }

  void _onTap() {
    if (_counts.isEmpty || _counts[_currentIndex] <= 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      _counts[_currentIndex]--;
      _recordTap();
    });
    if (_counts[_currentIndex] == 0 && _currentIndex < _counts.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  void dispose() {
    _persist();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    if (widget.azkarList.isEmpty) return const Scaffold(body: Center(child: Text('No Adhkar available.')));
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(azkarCategoryTitle(widget.categoryName)),
          actions: [
            IconButton(
              onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20, 48).toDouble()),
              icon: const Icon(Icons.text_fields),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Dhikr ${_currentIndex + 1} of ${widget.azkarList.length}',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_counts[_currentIndex]} remaining',
                    style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.azkarList.length,
                  minHeight: 6,
                  backgroundColor: cs.primaryContainer.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.azkarList.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = widget.azkarList[index];
                  final total = int.tryParse(item['count']?.toString() ?? '') ?? 1;
                  final remaining = _counts[index];
                  final progress = total <= 0 ? 1.0 : (1 - remaining / total).clamp(0.0, 1.0).toDouble();
                  final done = remaining == 0;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    item['zekr']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: _fontSize, height: 1.9, fontWeight: FontWeight.w700, color: cs.onSurface),
                                  ),
                                  if (item['description']?.toString().isNotEmpty == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 18),
                                      child: Text(
                                        item['description'].toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
                                      ),
                                    ),
                                  if (item['reference']?.toString().isNotEmpty == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2BC6B).withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          item['reference'].toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: index == _currentIndex ? _onTap : null,
                            child: SizedBox(
                              width: 148,
                              height: 148,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 148,
                                    height: 148,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 6,
                                      backgroundColor: cs.primaryContainer.withValues(alpha: 0.6),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9A24B)),
                                    ),
                                  ),
                                  Container(
                                    width: 122,
                                    height: 122,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.heroGradient(isDark),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF063D2E).withValues(alpha: 0.30),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: done
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 54)
                                          : Text(
                                              '$remaining',
                                              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            done ? 'Completed' : 'Tap to count',
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AzkarShareScreen(zekr: item, categoryName: widget.categoryName))),
                                  icon: const Icon(Icons.image_outlined),
                                  tooltip: 'Share image',
                                ),
                                IconButton(
                                  onPressed: () => SharePlus.instance.share(ShareParams(text: '${item['zekr']}\n\n${item['reference'] ?? ''}')),
                                  icon: const Icon(Icons.share_outlined),
                                  tooltip: 'Share',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
