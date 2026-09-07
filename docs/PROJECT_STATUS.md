# Imaanly Project Status

Updated: 2026-09-07

## Overall completion

**~76%**

## Recently completed

- Prayer notification scheduler connected to the calculated prayer lifecycle.
- Device timezone synchronization for scheduled local notifications.
- Persisted per-prayer notification preferences consumed by the scheduler.
- Dhikr local-first progress store with daily counter persistence.
- Dhikr daily goal updates and completed-day history persistence.
- Dhikr streak calculation wired to persisted completion history.
- Interactive Dhikr counter screen with live completion progress.
- Dhikr daily target selector with safe goal bounds.
- Dhikr counter controller connected to persistence and streak state.
- Dhikr completed-day history screen.
- Generic local reminder scheduling support for Dhikr reminders.
- Quran local-first reading position persistence.
- Quran daily page goal and progress persistence.
- Quran reading history persistence by day.
- Quran reading progress domain validation tests.
- Quran BLoC now loads persisted last-read position.
- Quran BLoC now persists last-read page and ayah through the repository.
- Quran dependency injection now provides the repository to the BLoC.
- Quran BLoC last-read persistence regression test.

## Completed foundation

- Imaanly rebrand/package/import migration
- Clean Architecture + BLoC foundation
- Centralized design tokens/UI primitives
- Home dashboard foundation
- Next-prayer countdown and prayer-time entry
- Home Qibla shortcut and Settings entry
- Qibla compass calibration/alignment
- Quran reader/Mushaf/search/resources/audio foundation
- Quran personalization bridge/init behavior
- Dhikr/Azkar foundation
- Daily goals + Dhikr integration
- Worship dashboard
- Islamic calendar foundation
- Fasting tracker foundation
- Islamic knowledge foundation
- Smart notification planner/coordinator
- Smart notification preference persistence and UI
- Platform local-notification delivery
- Prayer notification preferences, offsets and silent mode
- Prayer notification scheduling/orchestration
- Android exact-alarm/boot-reschedule configuration
- Flutter analyze/test CI workflow

## Remaining P0

- Real-device verification of exact alarms, reboot rescheduling and battery optimization.
- Actual Athan audio selection/playback.
- Device-level prayer/Qibla/location QA.

## Remaining P1

- Dhikr reminder Settings UI and recurring reminder management.
- Quran reader UI integration for persisted Continue Reading state.
- Quran history/goals UI integration.
- Hifz scheduling/progress.
- Worship analytics.
- Fasting active workflow/reminders/Ramadan behavior.
- Calendar event details/context.
- Duas/Hadith/Sunnah flows/favorites.

## Remaining P2

- Profile/settings/personalization/collections/accessibility/localization.

## Remaining P3

- Widgets/background refresh/offline QA/crash recovery/full device matrix/release signing.

AI/community/social features remain intentionally later and are not blocking the offline-first core product.
