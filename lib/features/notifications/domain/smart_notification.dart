import 'smart_notification_preferences.dart';

/// Categories used by Imaanly's contextual notification engine.
enum SmartNotificationCategory {
  prayer,
  quran,
  dhikr,
  streak,
}

class SmartNotificationCandidate {
  const SmartNotificationCandidate({
    required this.category,
    required this.title,
    required this.body,
    required this.reason,
  });

  final SmartNotificationCategory category;
  final String title;
  final String body;
  final String reason;
}

/// Deterministic, local-only notification policy.
class SmartNotificationPlanner {
  const SmartNotificationPlanner({
    this.prayerWindow = const Duration(minutes: 30),
    this.minimumPrayerLead = const Duration(minutes: 5),
  });

  final Duration prayerWindow;
  final Duration minimumPrayerLead;

  SmartNotificationCandidate? evaluate({
    required DateTime now,
    DateTime? nextPrayerAt,
    String? nextPrayerName,
    required int quranMinutesToday,
    int quranGoalMinutes = 0,
    required int dhikrCompletedToday,
    int dhikrGoal = 0,
    int currentStreak = 0,
    DateTime? lastActiveDay,
    SmartNotificationPreferences preferences = const SmartNotificationPreferences(),
  }) {
    if (preferences.maxNotificationsPerDay <= 0 || preferences.isQuietHour(now)) {
      return null;
    }

    if (preferences.isEnabled(SmartNotificationCategory.prayer) &&
        nextPrayerAt != null &&
        nextPrayerName != null) {
      final remaining = nextPrayerAt.difference(now);
      if (remaining >= minimumPrayerLead && remaining <= prayerWindow) {
        return SmartNotificationCandidate(
          category: SmartNotificationCategory.prayer,
          title: '$nextPrayerName is approaching',
          body: '${_formatMinutes(remaining.inMinutes)} minutes until $nextPrayerName.',
          reason: 'upcoming_prayer',
        );
      }
    }

    final quranNeedsWork = quranGoalMinutes > 0
        ? quranMinutesToday < quranGoalMinutes
        : quranMinutesToday <= 0;
    if (preferences.isEnabled(SmartNotificationCategory.quran) && quranNeedsWork) {
      return SmartNotificationCandidate(
        category: SmartNotificationCategory.quran,
        title: 'A moment for Quran',
        body: quranGoalMinutes > 0
            ? 'You are ${quranGoalMinutes - quranMinutesToday} minutes short of today\'s Quran goal.'
            : "You haven't read Quran today. Even a few minutes can keep your habit going.",
        reason: 'quran_goal',
      );
    }

    final dhikrNeedsWork = dhikrGoal > 0
        ? dhikrCompletedToday < dhikrGoal
        : dhikrCompletedToday <= 0;
    if (preferences.isEnabled(SmartNotificationCategory.dhikr) && dhikrNeedsWork) {
      return SmartNotificationCandidate(
        category: SmartNotificationCategory.dhikr,
        title: 'Remember Allah',
        body: dhikrGoal > 0
            ? 'You have ${dhikrGoal - dhikrCompletedToday} Dhikr remaining in today\'s goal.'
            : "You haven't recorded any Dhikr today. Take a quiet moment for remembrance.",
        reason: 'dhikr_goal',
      );
    }

    if (preferences.isEnabled(SmartNotificationCategory.streak) &&
        preferences.streakEnabled &&
        currentStreak > 0 &&
        _isStreakAtRisk(now, lastActiveDay)) {
      return SmartNotificationCandidate(
        category: SmartNotificationCategory.streak,
        title: 'Keep your $currentStreak-day streak',
        body: 'A small act of worship today can keep your streak alive.',
        reason: 'streak_risk',
      );
    }

    return null;
  }

  bool _isStreakAtRisk(DateTime now, DateTime? lastActiveDay) {
    if (lastActiveDay == null) return false;
    final last = DateTime(lastActiveDay.year, lastActiveDay.month, lastActiveDay.day);
    final today = DateTime(now.year, now.month, now.day);
    return last == today.subtract(const Duration(days: 1)) && now.hour >= 18;
  }

  String _formatMinutes(int minutes) => minutes <= 1 ? '1' : minutes.toString();
}
