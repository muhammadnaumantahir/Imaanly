# Imaanly Project Status

Updated: 2026-09-07

## Overall progress

**Estimated completion: ~61%**

This is a product-requirements estimate, not a code-line percentage. Existing inherited Quran functionality is substantial, while the newer Imaanly product layer still needs integration, complete workflows, background reliability, QA, and release hardening.

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
- Existing SettingsPage now reachable from the main Home dashboard
- Service-account dependency removed from the app workflow
- Permanent Flutter analyze/test CI workflow added

## Recently completed

### 2026-09-07
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

- Connect smart notification evaluation to real prayer/Quran/dhikr activity lifecycle
- Connect notification candidates to the platform local-notification delivery service
- Complete prayer notification controls: per-prayer enable/disable, reminder offsets, Athan/silent modes, sound behavior
- Verify Android notification permission, exact-alarm/background behavior and reboot rescheduling
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
