import '../domain/smart_notification.dart';
import '../domain/smart_notification_preferences.dart';
import '../services/local_notification_service.dart';
import 'smart_notification_coordinator.dart';

/// Application-facing bridge between notification policy and platform delivery.
///
/// Call [evaluate] whenever fresh worship/prayer state is available. The
/// coordinator enforces preferences, quiet hours and the daily fatigue limit;
/// the local service performs the actual platform delivery.
class SmartNotificationRuntime {
  SmartNotificationRuntime({
    SmartNotificationCoordinator? coordinator,
    LocalNotificationService? delivery,
  })  : _delivery = delivery ?? LocalNotificationService.instance,
        _coordinator = coordinator ??
            SmartNotificationCoordinator(
              deliver: (candidate) =>
                  (delivery ?? LocalNotificationService.instance)
                      .deliver(candidate),
            );

  final LocalNotificationService _delivery;
  final SmartNotificationCoordinator _coordinator;

  SmartNotificationPreferences get preferences => _coordinator.preferences;

  Future<void> initialize() async {
    await _delivery.initialize();
    await _coordinator.loadPreferences();
  }

  Future<bool> requestPermissions() => _delivery.requestPermissions();

  Future<void> savePreferences(SmartNotificationPreferences preferences) =>
      _coordinator.savePreferences(preferences);

  Future<SmartNotificationCandidate?> evaluate({
    required DateTime now,
    DateTime? nextPrayerAt,
    String? nextPrayerName,
    required int quranMinutesToday,
    int quranGoalMinutes = 0,
    required int dhikrCompletedToday,
    int dhikrGoal = 0,
    int currentStreak = 0,
    DateTime? lastActiveDay,
  }) {
    return _coordinator.evaluateAndDeliver(
      now: now,
      nextPrayerAt: nextPrayerAt,
      nextPrayerName: nextPrayerName,
      quranMinutesToday: quranMinutesToday,
      quranGoalMinutes: quranGoalMinutes,
      dhikrCompletedToday: dhikrCompletedToday,
      dhikrGoal: dhikrGoal,
      currentStreak: currentStreak,
      lastActiveDay: lastActiveDay,
    );
  }
}
