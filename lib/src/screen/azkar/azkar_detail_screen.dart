import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:al_furkan/features/dhikr/domain/dhikr_progress.dart';
import 'package:al_furkan/features/worship/data/worship_activity_repository.dart';
import 'package:al_furkan/src/screen/azkar/azkar_share_screen.dart';

class AzkarDetailScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> azkarList;
  final Color primary;

  const AzkarDetailScreen({super.key, required this.categoryName, required this.azkarList, required this.primary});

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  static const _defaultGoal = 33;
  late List<int> _counts;
  late PageController _pageController;
  int _currentIndex = 0;
  double _fontSize = 26.0;
  late DhikrProgress _dailyProgress;
  late Set<String> _completedDates;

  Box get _box => Hive.box('user');
  String get _progressKey => 'dhikr_progress_${widget.categoryName}';
  String get _historyKey => 'dhikr_completed_dates';
  String get _countsKey => '${_progressKey}_counts';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final savedFontSize = _box.get('azkar_detail_font_size', defaultValue: 26.0);
    _fontSize = savedFontSize is num ? savedFontSize.toDouble() : 26.0;
    _counts = widget.azkarList.map((e) => int.tryParse(e['count'].toString()) ?? 1).toList();
    _restoreProgress();
  }

  void _restoreProgress() {
    final today = DateTime.now();
    final todayKey = DhikrProgress.dateKeyFor(today);
    final saved = _box.get(_progressKey);
    _dailyProgress = saved is Map
        ? DhikrProgress.fromMap(saved).forDate(today)
        : DhikrProgress(goal: _defaultGoal, completed: 0, dateKey: todayKey);

    final history = _box.get(_historyKey, defaultValue: <dynamic>[]);
    _completedDates = history is List ? history.map((e) => e.toString()).toSet() : <String>{};

    final savedCounts = _box.get(_countsKey);
    if (savedCounts is Map && savedCounts['dateKey']?.toString() == todayKey) {
      final values = savedCounts['values'];
      if (values is Map) {
        for (var i = 0; i < _counts.length; i++) {
          final value = values[i.toString()];
          if (value is num) _counts[i] = value.toInt().clamp(0, _counts[i]);
        }
      }
    }
    _saveProgress();
    unawaited(_syncWorshipActivity());
  }

  Future<void> _syncWorshipActivity() async {
    try {
      final repository = await WorshipActivityRepository.openLocal();
      await repository.upsertDailyDhikr(
        category: widget.categoryName,
        completed: _dailyProgress.completed,
        goal: _dailyProgress.goal,
        date: DateTime.now(),
      );
    } catch (_) {
      // The existing Dhikr Hive progress remains the source of truth if the
      // unified worship store is temporarily unavailable.
    }
  }

  void _saveProgress() {
    _box.put(_progressKey, _dailyProgress.toMap());
    _box.put(_countsKey, {
      'dateKey': _dailyProgress.dateKey,
      'values': {for (var i = 0; i < _counts.length; i++) i.toString(): _counts[i]},
    });
    _box.put(_historyKey, _completedDates.toList());
  }

  void _recordTap() {
    _dailyProgress = _dailyProgress.increment();
    if (_dailyProgress.isGoalComplete) _completedDates.add(_dailyProgress.dateKey);
    _saveProgress();
    unawaited(_syncWorshipActivity());
  }

  void _onCountTap() {
    if (_counts[_currentIndex] <= 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      _counts[_currentIndex]--;
      _recordTap();
    });
    if (_counts[_currentIndex] == 0) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        if (_currentIndex < widget.azkarList.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الانتهاء من ${widget.categoryName}', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: widget.primary));
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F1E6);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: widget.primary), onPressed: () => Navigator.pop(context)),
          title: Text(widget.categoryName, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 20)),
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.text_fields_rounded, color: widget.primary), onPressed: _showFontSizeSheet)],
          bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: (_currentIndex + 1) / widget.azkarList.length, backgroundColor: widget.primary.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation<Color>(widget.primary))),
        ),
        body: Column(
          children: [
            const Gap(10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: _buildTodayProgress(isDark, textColor)),
            const Gap(10),
            Text('الذكر ${_currentIndex + 1} من ${widget.azkarList.length}', style: TextStyle(color: widget.primary.withValues(alpha: 0.8), fontWeight: FontWeight.w800, fontSize: 15)),
            const Gap(10),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: widget.azkarList.length,
                itemBuilder: (context, index) {
                  final zekr = widget.azkarList[index];
                  final originalCount = int.tryParse(zekr['count'].toString()) ?? 1;
                  final currentCount = _counts[index];
                  final isDone = currentCount == 0;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.68),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 10))]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              if (isDark) Positioned(top: -50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.primary.withValues(alpha: 0.15)))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 200),
                                              style: TextStyle(fontSize: _fontSize, height: 1.8, color: textColor, fontWeight: FontWeight.w700, fontFamily: 'KFGQPC-Uthmanic-HAFS-Regular'),
                                              child: Text(zekr['zekr'].toString(), textAlign: TextAlign.center),
                                            ),
                                            if (zekr['description'] != null && zekr['description'].toString().isNotEmpty) ...[
                                              const Gap(20),
                                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: widget.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Text(zekr['description'].toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: widget.primary))),
                                            ],
                                            if (zekr['reference'] != null && zekr['reference'].toString().isNotEmpty) ...[
                                              const Gap(16),
                                              Text(zekr['reference'].toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Gap(20),
                                    GestureDetector(
                                      onTap: _onCountTap,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: isDone ? 100 : 120,
                                        height: isDone ? 100 : 120,
                                        decoration: BoxDecoration(color: isDone ? widget.primary.withValues(alpha: 0.82) : widget.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: widget.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 10))]),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                            child: isDone
                                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 50, key: ValueKey('done'))
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    key: const ValueKey('counting'),
                                                    children: [
                                                      Text(currentCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                                                      if (originalCount > 1) Text('من $originalCount', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(icon: Icons.image_rounded, label: 'صورة', color: widget.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AzkarShareScreen(zekr: widget.azkarList[_currentIndex], categoryName: widget.categoryName)))),
                  _buildActionButton(icon: Icons.share_rounded, label: 'مشاركة', color: widget.primary, onTap: () {
                    final zekr = widget.azkarList[_currentIndex];
                    final text = zekr['zekr'].toString();
                    final ref = zekr['reference']?.toString() ?? '';
                    SharePlus.instance.share(ShareParams(text: '$text\n\n${ref.isNotEmpty ? 'المصدر: $ref\n' : ''}— أذكار المسلم'));
                  }),
                ],
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress(bool isDark, Color textColor) {
    final percent = _dailyProgress.completion;
    final streak = DhikrStreakCalculator.calculate(completedDates: _completedDates, today: DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: widget.primary.withValues(alpha: isDark ? 0.12 : 0.08), borderRadius: BorderRadius.circular(22), border: Border.all(color: widget.primary.withValues(alpha: 0.16))),
      child: Row(
        children: [
          SizedBox(width: 52, height: 52, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: percent, strokeWidth: 5, backgroundColor: widget.primary.withValues(alpha: 0.12), valueColor: AlwaysStoppedAnimation(widget.primary)), Text('${(percent * 100).round()}%', style: TextStyle(color: widget.primary, fontSize: 11, fontWeight: FontWeight.w900))])),
          const Gap(12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ورد اليوم', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)), const Gap(2), Text('${_dailyProgress.completed} من ${_dailyProgress.goal} • متبقي ${_dailyProgress.remaining}', style: TextStyle(color: textColor.withValues(alpha: 0.62), fontSize: 12, fontWeight: FontWeight.w600))])),
          if (streak > 0) const Gap(8),
          if (streak > 0) Column(children: [Icon(Icons.local_fire_department_rounded, color: widget.primary, size: 22), Text('$streak يوم', style: TextStyle(color: widget.primary, fontSize: 10, fontWeight: FontWeight.w800))]),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 20), const Gap(8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14))])));
  }

  void _showFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: sheetBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const Gap(24),
              Text('حجم الخط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
              const Gap(24),
              Row(children: [const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)), Expanded(child: Slider(value: _fontSize, min: 20, max: 60, activeColor: widget.primary, onChanged: (val) { setState(() => _fontSize = val); setSheetState(() {}); }, onChangeEnd: (val) => _box.put('azkar_detail_font_size', val))), const Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey))]),
              const Gap(24),
              const Text('اسحب الشريط لتكبير أو تصغير الخط. سيتم حفظ الإعداد تلقائياً.', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const Gap(32),
            ]),
          );
        });
      },
    );
  }
}
