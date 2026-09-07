/// Categories used by Imaanly's contextual notification engine.
enum SmartNotificationCategory {
  prayer,
  quran,
  dhikr,
}

/// A notification recommendation produced from local app state.
///
/// The planner is deliberately pure and deterministic. It does not send a
/// notification itself, which keeps notification policy testable and lets the
/// platform-specific scheduler decide how/when to deliver it.
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

/// Local, privacy-preserving notification policy for the Imaanly companion.
///
/// Rules are intentionally conservative to avoid notification fatigue:
/// - never emit more than one candidate for a single evaluation;
/// - prefer an upcoming prayer when it is close;
/// - otherwise remind about Quran when today's reading is still zero;
/// - otherwise remind about Dhikr when today's progress is still zero;
/// - otherwise stay silent.
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
    required int dhikrCompletedToday,
  }) {
    if (nextPrayerAt != null && nextPrayerName != null) {
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

    if (quranMinutesToday <= 0) {
      return const SmartNotificationCandidate(
        category: SmartNotificationCategory.quran,
        title: 'A moment for Quran',
        body: "You haven't read Quran today. Even a few minutes can keep your habit going.",
        reason: 'no_quran_today',
      );
    }

    if (dhikrCompletedToday <= 0) {
      return const SmartNotificationCandidate(
        category: SmartNotificationCategory.dhikr,
        title: 'Remember Allah',
        body: "You haven't recorded any Dhikr today. Take a quiet moment for remembrance.",
        reason: 'no_dhikr_today',
      );
    }

    return null;
  }

  String _formatMinutes(int minutes) => minutes <= 1 ? '1' : minutes.toString();
}
