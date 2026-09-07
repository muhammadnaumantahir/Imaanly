import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_preferences.dart';

void main() {
  test('quiet hours cover overnight window', () {
    const preferences = SmartNotificationPreferences();
    expect(preferences.isQuietHour(DateTime(2026, 9, 7, 23)), isTrue);
    expect(preferences.isQuietHour(DateTime(2026, 9, 8, 6)), isTrue);
    expect(preferences.isQuietHour(DateTime(2026, 9, 7, 14)), isFalse);
  });

  test('category switches are independently respected', () {
    const preferences = SmartNotificationPreferences(
      prayerEnabled: false,
      quranEnabled: true,
      dhikrEnabled: false,
      streakEnabled: true,
    );
    expect(preferences.isEnabled(SmartNotificationCategory.prayer), isFalse);
    expect(preferences.isEnabled(SmartNotificationCategory.quran), isTrue);
    expect(preferences.isEnabled(SmartNotificationCategory.dhikr), isFalse);
  });

  test('notification limit cannot be negative in normal policy', () {
    const preferences = SmartNotificationPreferences(maxNotificationsPerDay: 0);
    expect(preferences.maxNotificationsPerDay, 0);
  });
}
