import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:imaanly/src/core/storage/app_boxes.dart";

class ReadingHistoryDay {
  final String date;
  final int pages;
  final int ayahs;
  final int seconds;

  const ReadingHistoryDay({
    required this.date,
    this.pages = 0,
    this.ayahs = 0,
    this.seconds = 0,
  });

  ReadingHistoryDay copyWith({int? pages, int? ayahs, int? seconds}) => ReadingHistoryDay(
        date: date,
        pages: pages ?? this.pages,
        ayahs: ayahs ?? this.ayahs,
        seconds: seconds ?? this.seconds,
      );
}

class ReadingStatsState {
  final int pagesToday;
  final int ayahsToday;
  final int secondsToday;
  final int streak;
  final int dailyGoalPages;
  final int dailyGoalAyahs;
  final String? lastActiveDate;
  final int totalPagesAllTime;
  final int totalAyahsAllTime;
  final List<ReadingHistoryDay> history;

  const ReadingStatsState({
    this.pagesToday = 0,
    this.ayahsToday = 0,
    this.secondsToday = 0,
    this.streak = 0,
    this.dailyGoalPages = 0,
    this.dailyGoalAyahs = 0,
    this.lastActiveDate,
    this.totalPagesAllTime = 0,
    this.totalAyahsAllTime = 0,
    this.history = const [],
  });

  ReadingStatsState copyWith({
    int? pagesToday,
    int? ayahsToday,
    int? secondsToday,
    int? streak,
    int? dailyGoalPages,
    int? dailyGoalAyahs,
    String? lastActiveDate,
    int? totalPagesAllTime,
    int? totalAyahsAllTime,
    List<ReadingHistoryDay>? history,
  }) => ReadingStatsState(
        pagesToday: pagesToday ?? this.pagesToday,
        ayahsToday: ayahsToday ?? this.ayahsToday,
        secondsToday: secondsToday ?? this.secondsToday,
        streak: streak ?? this.streak,
        dailyGoalPages: dailyGoalPages ?? this.dailyGoalPages,
        dailyGoalAyahs: dailyGoalAyahs ?? this.dailyGoalAyahs,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        totalPagesAllTime: totalPagesAllTime ?? this.totalPagesAllTime,
        totalAyahsAllTime: totalAyahsAllTime ?? this.totalAyahsAllTime,
        history: history ?? this.history,
      );

  double get goalProgress {
    if (dailyGoalPages > 0) return (pagesToday / dailyGoalPages).clamp(0.0, 1.0);
    if (dailyGoalAyahs > 0) return (ayahsToday / dailyGoalAyahs).clamp(0.0, 1.0);
    return 0.0;
  }

  bool get hasGoal => dailyGoalPages > 0 || dailyGoalAyahs > 0;
  bool get goalReached => goalProgress >= 1.0;

  String get formattedTimeToday {
    final mins = secondsToday ~/ 60;
    final hrs = mins ~/ 60;
    final remMins = mins % 60;
    if (hrs > 0) return "$hrs ساعة $remMins دقيقة";
    if (mins > 0) return "$mins دقيقة";
    return "$secondsToday ثانية";
  }
}

class ReadingStatsCubit extends Cubit<ReadingStatsState> {
  static const _kBox = AppBoxes.readingStats;
  static const _kPagesToday = "pages_today";
  static const _kAyahsToday = "ayahs_today";
  static const _kSecondsToday = "seconds_today";
  static const _kStreak = "streak";
  static const _kDailyGoalPages = "daily_goal_pages";
  static const _kDailyGoalAyahs = "daily_goal_ayahs";
  static const _kLastActiveDate = "last_active_date";
  static const _kTotalPages = "total_pages";
  static const _kTotalAyahs = "total_ayahs";
  static const _kHistory = "daily_history";

  ReadingStatsCubit() : super(const ReadingStatsState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box(_kBox);
    final today = _todayString();
    final lastDate = box.get(_kLastActiveDate) as String?;
    final isSameDay = lastDate == today;
    final pagesToday = isSameDay ? (box.get(_kPagesToday, defaultValue: 0) as int) : 0;
    final ayahsToday = isSameDay ? (box.get(_kAyahsToday, defaultValue: 0) as int) : 0;
    final secondsToday = isSameDay ? (box.get(_kSecondsToday, defaultValue: 0) as int) : 0;

    int streak = box.get(_kStreak, defaultValue: 0) as int;
    if (!isSameDay && lastDate != _yesterdayString() && lastDate != null) streak = 0;
    if (pagesToday > 0 || ayahsToday > 0) streak = streak > 0 ? streak : 1;

    emit(ReadingStatsState(
      pagesToday: pagesToday,
      ayahsToday: ayahsToday,
      secondsToday: secondsToday,
      streak: streak,
      dailyGoalPages: box.get(_kDailyGoalPages, defaultValue: 0) as int,
      dailyGoalAyahs: box.get(_kDailyGoalAyahs, defaultValue: 0) as int,
      lastActiveDate: lastDate,
      totalPagesAllTime: box.get(_kTotalPages, defaultValue: 0) as int,
      totalAyahsAllTime: box.get(_kTotalAyahs, defaultValue: 0) as int,
      history: _readHistory(box),
    ));
  }

  List<ReadingHistoryDay> _readHistory(Box box) {
    final raw = box.get(_kHistory);
    if (raw is! Map) return const [];
    final days = <ReadingHistoryDay>[];
    raw.forEach((key, value) {
      if (key is! String || value is! Map) return;
      days.add(ReadingHistoryDay(
        date: key,
        pages: (value['pages'] as num?)?.toInt() ?? 0,
        ayahs: (value['ayahs'] as num?)?.toInt() ?? 0,
        seconds: (value['seconds'] as num?)?.toInt() ?? 0,
      ));
    });
    days.sort((a, b) => b.date.compareTo(a.date));
    return days;
  }

  void _saveHistory(Box box, String date, {int pages = 0, int ayahs = 0, int seconds = 0}) {
    final raw = box.get(_kHistory);
    final history = <dynamic, dynamic>{};
    if (raw is Map) history.addAll(raw);
    final current = raw is Map && raw[date] is Map ? Map<dynamic, dynamic>.from(raw[date] as Map) : <dynamic, dynamic>{};
    current['pages'] = ((current['pages'] as num?)?.toInt() ?? 0) + pages;
    current['ayahs'] = ((current['ayahs'] as num?)?.toInt() ?? 0) + ayahs;
    current['seconds'] = ((current['seconds'] as num?)?.toInt() ?? 0) + seconds;
    history[date] = current;
    box.put(_kHistory, history);
  }

  void recordPages(int pages) {
    if (pages <= 0) return;
    final box = Hive.box(_kBox);
    final today = _todayString();
    final newPages = state.pagesToday + pages;
    final newTotal = state.totalPagesAllTime + pages;
    box.put(_kPagesToday, newPages);
    box.put(_kTotalPages, newTotal);
    box.put(_kLastActiveDate, today);
    _saveHistory(box, today, pages: pages);
    final streak = _updateStreak(box, today);
    emit(state.copyWith(pagesToday: newPages, totalPagesAllTime: newTotal, lastActiveDate: today, streak: streak, history: _readHistory(box)));
  }

  void recordAyahs(int ayahs) {
    if (ayahs <= 0) return;
    final box = Hive.box(_kBox);
    final today = _todayString();
    final newAyahs = state.ayahsToday + ayahs;
    final newTotal = state.totalAyahsAllTime + ayahs;
    box.put(_kAyahsToday, newAyahs);
    box.put(_kTotalAyahs, newTotal);
    box.put(_kLastActiveDate, today);
    _saveHistory(box, today, ayahs: ayahs);
    final streak = _updateStreak(box, today);
    emit(state.copyWith(ayahsToday: newAyahs, totalAyahsAllTime: newTotal, lastActiveDate: today, streak: streak, history: _readHistory(box)));
  }

  void recordTime(int seconds) {
    if (seconds <= 0) return;
    final box = Hive.box(_kBox);
    final today = _todayString();
    final newSeconds = state.secondsToday + seconds;
    box.put(_kSecondsToday, newSeconds);
    box.put(_kLastActiveDate, today);
    _saveHistory(box, today, seconds: seconds);
    emit(state.copyWith(secondsToday: newSeconds, lastActiveDate: today, history: _readHistory(box)));
  }

  void setDailyGoal({int pages = 0, int ayahs = 0}) {
    final box = Hive.box(_kBox);
    box.put(_kDailyGoalPages, pages);
    box.put(_kDailyGoalAyahs, ayahs);
    emit(state.copyWith(dailyGoalPages: pages, dailyGoalAyahs: ayahs));
  }

  int _updateStreak(Box box, String today) {
    int streak = state.streak;
    final lastDate = state.lastActiveDate;
    if (lastDate == today) {
      // Same day.
    } else if (lastDate == _yesterdayString()) {
      streak++;
    } else {
      streak = 1;
    }
    box.put(_kStreak, streak);
    return streak;
  }

  String _todayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _yesterdayString() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return "${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}";
  }
}
