import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/quran_reading_progress.dart';

/// Persists the last Quran reading position plus daily reading progress.
class QuranReadingProgressStore {
  static const _boxName = 'user';
  static const _progressKey = 'quran_reading_progress';
  static const _historyKey = 'quran_reading_history';

  const QuranReadingProgressStore();

  Future<QuranReadingProgress> load([DateTime? date]) async {
    final box = await _openBox();
    final raw = box.get(_progressKey);
    final stored = raw is Map
        ? QuranReadingProgress.fromMap(raw)
        : const QuranReadingProgress(
            surahNumber: 1,
            ayahNumber: 1,
            dailyPages: 0,
            dailyPageGoal: 2,
            dateKey: '',
          );
    final key = _dateKey(date ?? DateTime.now());
    if (stored.dateKey == key) return stored;
    return stored.copyWith(dailyPages: 0, dateKey: key);
  }

  Future<void> save(QuranReadingProgress progress) async {
    final box = await _openBox();
    await box.put(_progressKey, progress.toMap());
    final history = _readHistory(box);
    history[progress.dateKey] = progress.dailyPages;
    await box.put(_historyKey, history);
  }

  Future<void> updatePosition({required int surahNumber, required int ayahNumber}) async {
    final progress = await load();
    await save(progress.copyWith(
      surahNumber: surahNumber.clamp(1, 114).toInt(),
      ayahNumber: ayahNumber.clamp(1, 1000).toInt(),
    ));
  }

  Future<QuranReadingProgress> addPages(int pages) async {
    final progress = await load();
    final next = progress.copyWith(dailyPages: progress.dailyPages + pages.clamp(0, 100).toInt());
    await save(next);
    return next;
  }

  Future<void> setDailyPageGoal(int goal) async {
    final progress = await load();
    await save(progress.copyWith(dailyPageGoal: goal.clamp(1, 1000).toInt()));
  }

  Future<Map<String, int>> loadHistory() async {
    final box = await _openBox();
    return _readHistory(box);
  }

  Map<String, int> _readHistory(Box box) {
    final raw = box.get(_historyKey);
    if (raw is Map) {
      return raw.map((key, value) {
        final parsed = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
        return MapEntry(key.toString(), parsed < 0 ? 0 : parsed);
      });
    }
    return <String, int>{};
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
