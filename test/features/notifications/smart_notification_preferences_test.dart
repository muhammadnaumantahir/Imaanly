import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/notifications/domain/smart_notification.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_category.dart';
import 'package:imaanly/features/notifications/domain/smart_notification_preferences.dart';

void main() {
  test('quiet hours cover overnight window', () {
    const preferences = SmartNotificationPreferences();
    expect(preferences.isQuietHour(DateTime(2026, 9, 7, 23)), isTrue);
    expect(preferences.isQuietHour(DateTime(2026, 9, 8, 6)), isTrue);
    expect(preferences.isQuietHour(DateTime(2026, 9, 7, 14)), isFalse);
  });

  test('category switches are independently respected', () {
    const preferences = SmartNotificationPreferences(prayerEnabled: false, quranEnabled: true, dhikrEnabled: false, streakEnabled: true);
    expect(preferences.isEnabled(SmartNotificationCategory.prayer), isFalse);
    expect(preferences.isEnabled(SmartNotificationCategory.quran), isTrue);
    expect(preferences.isEnabled(SmartNotificationCategory.dhikr), isFalse);
  });

  test('copyWith changes only requested fields', () {
    const original = SmartNotificationPreferences();
    final updated = original.copyWith(quranEnabled: false, maxNotificationsPerDay: 3);
    expect(updated.quranEnabled, isFalse);
    expect(updated.maxNotificationsPerDay, 3);
    expect(updated.prayerEnabled, isTrue);
    expect(updated.quietStartHour, 22);
  });

  test('preferences survive map serialization', () {
    const original = SmartNotificationPreferences(prayerEnabled: false, quranEnabled: true, dhikrEnabled: false, streakEnabled: true, maxNotificationsPerDay: 5, quietStartHour: 21, quietEndHour: 6);
    final restored = SmartNotificationPreferences.fromMap(original.toMap());
    expect(restored.prayerEnabled, original.prayerEnabled);
    expect(restored.quranEnabled, original.quranEnabled);
    expect(restored.dhikrEnabled, original.dhikrEnabled);
    expect(restored.streakEnabled, original.streakEnabled);
    expect(restored.maxNotificationsPerDay, original.maxNotificationsPerDay);
    expect(restored.quietStartHour, original.quietStartHour);
    expect(restored.quietEndHour, original.quietEndHour);
  });

  test('notification limit can be disabled with zero', () {
    const preferences = SmartNotificationPreferences(maxNotificationsPerDay: 0);
    expect(preferences.maxNotificationsPerDay, 0);
  });
}
