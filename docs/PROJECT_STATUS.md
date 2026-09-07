# Imaanly Project Status

Updated: 2026-09-07

## Overall completion

**~85%**

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
- Quran BLoC loads persisted last-read position and immediately loads that page.
- Quran BLoC persists page navigation and selected ayah positions.
- Quran reader restores the persisted page and keeps the PageView synchronized with saved state.
- Quran feature dependencies are registered during app bootstrap.
- Unified Quran persistence keys with the existing Mushaf last-read keys.
- Quran reading progress screen exposes today's pages, ayahs, time, streak and all-time totals.
- Quran daily page goal can be created, changed or cleared from the progress screen.
- Quran reader now exposes the reading-progress screen directly from its AppBar.
- Hifz review scheduling is centralized in a pure-Dart domain service.
- Hifz spaced-repetition intervals are covered by automated domain tests.
- Hifz due-review repository logic now consumes the shared scheduling rules.
- Interactive Hifz review session with per-ayah correct/mistake tracking.
- Hifz review results persist updated accuracy, mastery, review counts and mistakes.
- Hifz review sessions persist duration, hints and session type.
- Hifz dashboard due-review and progress cards now launch the review workflow.
- Hifz review mastery thresholds are covered by automated tests.
- Hifz review completion now uses a single BLoC operation to persist progress and the session sequentially.
- Hifz review completion refreshes progress, recent sessions, due reviews and aggregate statistics together.
- Hifz new-memorization screen supports selecting any Surah and a validated ayah range.
- Hifz dashboard now exposes Start New Memorization and an empty-state onboarding action.

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

- Connect the new Quran reader to the main Continue Reading/home entry.
- Quran history/goals deeper integration and historical trend UI.
- Dhikr reminder Settings UI and recurring reminder management.
- Hifz richer memorization/review content and Quran text/audio integration.
- Worship analytics/history beyond the current daily dashboard.
- Fasting active workflow/reminders/Ramadan behavior.
- Calendar event details/context.
- Duas/Hadith/Sunnah flows/favorites.

## Remaining P2

- Profile/settings/personalization/collections/accessibility/localization.

## Remaining P3

- Widgets/background refresh/offline QA/crash recovery/full device matrix/release signing.

AI/community/social features remain intentionally later and are not blocking the offline-first core product.
