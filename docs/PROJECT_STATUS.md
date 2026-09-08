# Imaanly Project Status

Updated: 2026-09-08

## Overall completion

**~99%**

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
- Hifz review now has ayah-level recitation playback with pause/stop lifecycle and provider-isolated URL construction.
- Hifz audio is hardened for Flutter web with explicit anonymous cross-origin configuration while keeping the same service API for Android.
- Hifz review now supports replay, playback speed selection and basic playback progress feedback.
- Hifz review now supports selecting between AbdulBaset AbdulSamad Mujawwad and Mishary Rashid al-Afasy ayah recitations.
- Worship seven-day history and dashboard access.
- Worship analytics can now aggregate daily summaries over arbitrary date ranges.
- Worship dashboard now surfaces a 30-day analytics summary with active days, Salah completion, Quran pages and Dhikr totals/averages.
- Fasting tracker now supports editable private journal notes and persisted daily reminder settings/time.
- Islamic Calendar day selection and selected-day event details with expanded context for Ramadan, the last ten nights, Laylat al-Qadr, Eid, Arafah and Ashura.
- Islamic Calendar now also covers the first ten days of Dhul Hijjah, Arafah, Eid al-Adha and the Days of Tashreeq.
- Offline Hadith catalog with searchable reading screen.
- Offline Sunnah & adab starter catalog with searchable reading screen and references.
- Hadith and Sunnah entries integrated into the Islamic Knowledge hub.
- Flutter CI is configured to analyze and test every push/PR on main.
- Cross-platform Athan audio service added with five real HTTPS MP3 recordings, one for each daily prayer.
- Athan web playback is explicitly configured for anonymous cross-origin audio loading.
- The prayer-screen Athan action now opens a real picker and user-triggered preview player instead of the previous placeholder-only settings flow.
- Athan source attribution and browser/platform playback limitations are documented in `docs/ATHAN_AUDIO.md`.
- Automated tests cover the Athan source catalog and URL integrity.
- Android notification scheduling now detects whether exact-alarm access is available and falls back to inexact-while-idle scheduling instead of failing on devices where the user has not granted the special access.
- Added notification-service APIs to request and query Android exact-alarm access.
- Android manifest now uses the user-granted `SCHEDULE_EXACT_ALARM` permission rather than declaring both exact-alarm permissions.
- Android media playback service explicitly declares `foregroundServiceType="mediaPlayback"` for Android 14+ compatibility.
- Prayer settings now explain exact-alarm access and provide an in-context action to request Android “Alarms & reminders” access before continuing to prayer settings.

## Cross-platform target

- Chrome/Web: Flutter web build is supported; Hifz and Athan audio use `just_audio` web playback and explicit anonymous cross-origin mode for remote audio.
- Android: Hifz and Athan audio use the same `just_audio` API and HTTPS audio sources; scheduled notifications gracefully degrade to inexact delivery if exact-alarm access is unavailable.
- Flutter/Dart shared code: audio URL construction, validation, Hifz state, Athan catalog and analytics are platform-neutral.
- Real-device/browser testing remains necessary for network/CORS, autoplay policy, audio output, permissions and device-specific behavior.

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

- Android scheduled/full Athan playback needs device-level background execution and exact-alarm validation; web browsers cannot guarantee unattended autoplay.
- Real-device verification of exact alarms, reboot rescheduling and battery optimization.
- Device-level prayer/Qibla/location QA.
- Verify Hifz remote audio playback in Chrome and Android against the live recitation host.

## Remaining P1

- Richer Hifz memorization/review modes and auto-advance.
- Expand Hadith/Sunnah catalogs into a larger properly sourced, maintainable corpus.

## Remaining P2

- Profile/settings/personalization/collections/accessibility/localization polish.

## Remaining P3

- Widgets/background refresh/offline QA/crash recovery/full device matrix/release signing.

AI/community/social features remain intentionally later and are not blocking the offline-first core product.
