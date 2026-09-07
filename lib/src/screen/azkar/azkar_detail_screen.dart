import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:imaanly/features/dhikr/domain/dhikr_progress.dart';
import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/src/screen/azkar/azkar_share_screen.dart';

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
    if (widget.azkarList.isEmpty) return const Scaffold(body: Center(child: Text('No Adhkar available.')));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          actions: [
            IconButton(
              onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20, 48).toDouble()),
              icon: const Icon(Icons.text_fields),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_currentIndex + 1) / widget.azkarList.length),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'الذكر ${_currentIndex + 1} من ${widget.azkarList.length} • المتبقي ${_counts[_currentIndex]}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.azkarList.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = widget.azkarList[index];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      item['zekr']?.toString() ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: _fontSize, height: 1.8, fontWeight: FontWeight.w700, color: isDark ? Colors.white : null),
                                    ),
                                    if (item['description']?.toString().isNotEmpty == true)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 18),
                                        child: Text(item['description'].toString(), textAlign: TextAlign.center),
                                      ),
                                    if (item['reference']?.toString().isNotEmpty == true)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: Text(item['reference'].toString(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: index == _currentIndex ? _onTap : null,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(color: widget.primary, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${_counts[index]}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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
