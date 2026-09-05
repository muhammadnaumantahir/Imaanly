class DhikrProgress {
  final int goal;
  final int completed;
  final String dateKey;

  const DhikrProgress({
    required this.goal,
    required this.completed,
    this.dateKey = '',
  });

  int get remaining => (goal - completed).clamp(0, goal);

  double get completion => goal <= 0 ? 0 : (completed / goal).clamp(0, 1).toDouble();

  bool get isGoalComplete => completed >= goal;

  DhikrProgress increment([int amount = 1]) {
    if (amount <= 0) return this;
    return DhikrProgress(
      goal: goal,
      completed: (completed + amount).clamp(0, goal),
      dateKey: dateKey,
    );
  }

  DhikrProgress forDate(DateTime date) {
    final key = _dateKey(date);
    if (dateKey == key) return this;
    return DhikrProgress(goal: goal, completed: 0, dateKey: key);
  }

  Map<String, dynamic> toMap() => {
        'goal': goal,
        'completed': completed,
        'dateKey': dateKey,
      };

  factory DhikrProgress.fromMap(Map<dynamic, dynamic> map) {
    return DhikrProgress(
      goal: (map['goal'] as num?)?.toInt() ?? 33,
      completed: (map['completed'] as num?)?.toInt() ?? 0,
      dateKey: map['dateKey']?.toString() ?? '',
    );
  }

  static String dateKeyFor(DateTime date) => _dateKey(date);

  static String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

class DhikrStreakCalculator {
  const DhikrStreakCalculator._();

  static int calculate({
    required Set<String> completedDates,
    required DateTime today,
  }) {
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    while (completedDates.contains(DhikrProgress.dateKeyFor(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
