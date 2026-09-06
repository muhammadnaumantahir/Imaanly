import 'package:imaanly/features/worship/data/worship_activity_repository.dart';
import 'package:imaanly/features/worship/domain/worship_daily_summary.dart';

import '../domain/worship_analytics.dart';

class WorshipAnalyticsService {
  WorshipAnalyticsService(this._repository);

  final WorshipActivityRepository _repository;

  Future<WorshipAnalyticsReport> loadWeek({DateTime? through}) async {
    final end = _dateOnly(through ?? DateTime.now());
    final activities = await _repository.getAll();
    final days = <WorshipAnalyticsDay>[];

    for (var offset = 6; offset >= 0; offset--) {
      final date = end.subtract(Duration(days: offset));
      final summary = WorshipDailySummary.fromActivities(
        activities,
        date: date,
      );
      days.add(WorshipAnalyticsDay(date: date, summary: summary));
    }

    return WorshipAnalyticsReport(days: List.unmodifiable(days));
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
