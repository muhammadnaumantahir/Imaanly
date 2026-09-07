# Imaanly Project Status

Updated: 2026-09-07

## Overall progress

**Estimated completion: ~67%**

This is a product-requirements estimate, not a code-line percentage. Existing inherited Quran functionality is substantial, while the newer Imaanly product layer still needs deeper workflow integration, background reliability, QA, and release hardening.

## Completed / substantially implemented

- Imaanly rebrand and package/import migration
- Clean Architecture + BLoC foundation
- Centralized Imaanly design tokens and reusable UI primitives
- Home dashboard foundation
- Live next-prayer countdown and prayer-time entry point
- Home Qibla shortcut connected to the real compass screen
- Home Settings entry point connected to the existing SettingsPage
- Qibla compass implementation with calibration/alignment behavior
- Quran reader / Mushaf / search / resources / audio foundation
- Quran personalization bridge and initialization behavior
- Dhikr/Azkar feature foundation
- Daily goals foundation, including Dhikr goal integration
- Worship dashboard foundation
- Islamic calendar foundation
- Fasting tracker foundation
- Islamic knowledge foundation
- Smart notification planner/coordinator with category policy, quiet hours and daily fatigue limits
- Smart notification preferences persistence in Hive
- Notification preferences UI for prayer/Quran/dhikr/streak categories, daily limits and quiet hours
- Automated tests for notification preference behavior and serialization
- Platform local-notification delivery service
- Smart notification runtime bridge from policy to device delivery
- Per-prayer notification preference model with individual Fajr/Dhuhr/Asr/Maghrib/Isha controls
- Local persistence store for per-prayer notification preferences
- User-facing per-prayer notification toggles in Settings
- User-facing prayer reminder offset selector (0–60 minutes)
- User-facing silent prayer reminder control
- Scheduled prayer reminder delivery with configurable reminder lead time and silent mode
- Stable prayer/date notification IDs so rescheduling does not create duplicate alarms
- Prayer notification scheduler/orchestrator that applies per-prayer preferences to calculated daily prayer times
- Android exact-alarm, notification and boot-reschedule permissions/receivers are present
- Existing SettingsPage now reachable from the main Home dashboard
- Service-account dependency removed from the app workflow
- Permanent Flutter analyze/test CI workflow added

## Recently completed

### 2026-09-07
- `b2fa8b2` — added user-facing per-prayer notification settings, reminder offset and silent mode
- `17daece` — added local Hive persistence for per-prayer notification preferences
- `3b0cfa6` — added prayer notification scheduler/orchestrator for calculated daily schedules
- `8cca076` — added scheduled prayer reminder delivery with timezone-aware scheduling
- `94210eb` — added per-prayer notification preference model
- `632606e` — connected smart notification runtime and updated progress documentation
- `6b9db7b` — added smart notification runtime bridge
- `0047ebf` — added platform local notification delivery service
- `47d5eb1` — connected Home Qibla quick action to `QiblaDirection`
- `795eee7` — added copy/serialization support to smart notification preferences
- `e39edb6` — persisted smart notification preferences through Hive
- `2790248` — added notification preferences screen
- `9006555` — normalized persisted integer settings
- `5c89419` — fixed quiet-hour endpoint persistence
- `daadb12` — expanded notification preference tests
- `2c1ada1` — exposed Settings from the Home dashboard

## Remaining priority work

### P0 — make the product operational end-to-end

- Call the prayer notification scheduler from the actual prayer calculation/location refresh lifecycle
- Connect persisted per-prayer preferences to the scheduler instead of using defaults
- Add robust timezone selection/synchronization for scheduled alarms using the device timezone
- Add actual Athan audio selection/playback for prayer notifications
- Verify Android exact-alarm permission behavior on supported Android versions
- Verify notification delivery, reboot rescheduling and battery-optimization edge cases on real devices
- Finish device-level prayer/Qibla/location QA

### P1 — complete core worship workflows

- Dhikr interactive counter, targets, completion history, streaks and reminder flow
- Quran reading continuation based on actual last position rather than a fixed starting location
- Quran progress/history polish and daily reading goals
- Hifz revision scheduling and stronger progress workflow
- Worship analytics: daily/weekly/monthly trends and meaningful empty states
- Fasting: active fast workflow, Suhoor/Iftar reminders, missed/completed states and Ramadan-oriented behavior
- Islamic calendar event details and contextual Home integration
- Duas/Hadith/Sunnah content flows and favorites/collections where required

### P2 — personalization and account experience

- Profile experience and user-facing preferences
- Expand Settings into a complete product settings hub
- Personalization controls for Home sections, Quran behavior and worship targets
- Collections/bookmarks/notes management polish
- Accessibility, localization and typography audit

### P3 — platform/release

- Android/iOS widget implementation and configuration
- Background refresh/reliable scheduling
- Offline/resource storage QA
- Crash/error states and recovery UX
- Full test matrix on real devices
- Release signing/build configuration and store-readiness checklist

## Intentional non-goals / later phases

AI/community/social features should not block the core offline-first worship product. They can be added after the core experience, reliability, privacy and release QA are complete.

## Definition of done

The project should not be considered 100% complete until the major requirements are not only represented by screens/classes, but are connected into complete user workflows, persist correctly, behave reliably in background/device conditions, and pass automated plus real-device QA.
