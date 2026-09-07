# Imaanly Project Status

Updated: 2026-09-07

## Overall completion

**~96%**

## Recently completed

- Prayer notification scheduler connected to the calculated prayer lifecycle.
- Device timezone synchronization for scheduled local notifications.
- Persisted per-prayer notification preferences consumed by the scheduler.
- Dhikr local-first progress, goals, streaks and recurring reminders.
- Interactive Adhkar counter with sharing and saved favorites.
- Dedicated local-first Dua/Adhkar favorites collection.
- Quran local-first reading position, daily goals, history and seven-day trend.
- Quran reader restores persisted position and navigation progress.
- Hifz scheduling, interactive review, scoring, persistence, mastery and new memorization ranges.
- Hifz review can reveal local Mushaf text and limited Arabic hints.
- Worship seven-day history and dashboard access.
- Fasting tracker now supports editable private journal notes and persisted daily reminder settings/time.
- Islamic Calendar day selection and selected-day event details.
- Offline Hadith catalog with searchable reading screen.
- Offline Sunnah & adab starter catalog with searchable reading screen and references.
- Hadith and Sunnah entries integrated into the Islamic Knowledge hub.

## Completed foundation

- Imaanly rebrand/package/import migration
- Clean Architecture + BLoC foundation
- Centralized design tokens/UI primitives
- Home dashboard
- Prayer countdown/time entry and notification scheduling
- Qibla shortcut, settings and calibration
- Quran reader/Mushaf/search/resources/audio foundation
- Quran personalization bridge
- Dhikr/Azkar and worship dashboard
- Islamic calendar
- Fasting tracker
- Islamic knowledge hub
- Tafsir foundation
- Collections foundation
- Smart notification planner/coordinator and local notifications
- Android exact-alarm/boot-reschedule configuration
- Flutter analyze/test CI workflow

## Remaining P0

- Real-device verification of exact alarms, reboot rescheduling and battery optimization.
- Actual Athan audio selection/playback.
- Device-level prayer/Qibla/location QA.

## Remaining P1

- Hifz audio integration and richer memorization/review content.
- Worship analytics/history beyond seven-day history.
- Calendar event details/context beyond the current built-in occasion set.
- Expand Hadith/Sunnah catalogs into a larger properly sourced, maintainable corpus.

## Remaining P2

- Profile/settings/personalization/collections/accessibility/localization polish.

## Remaining P3

- Widgets/background refresh/offline QA/crash recovery/full device matrix/release signing.

AI/community/social features remain intentionally later and are not blocking the offline-first core product.
