# Global Prayer Companion — Product Requirements

## 1. Product intent

Build a free, English-first Islamic companion for Android and iOS. The first release must feel like a trustworthy Athan-style prayer app: fast, calm, accurate, privacy-conscious, and pleasant enough to open several times every day.

The product launches without advertising, subscriptions, accounts, or required cloud storage. It supports a global audience, while English is the first user-interface language.

## 2. Product principles

- Prayer is the primary daily job; the home screen opens to today's schedule, not the Quran reader.
- Accuracy and transparency beat visual novelty. Users can inspect and change every calculation setting affecting a prayer time.
- Location is optional. Manual city/location entry must be a first-class path.
- Personal data stays on-device unless a future, opt-in account feature explicitly changes this.
- The interface is accessible: readable type, high contrast, scalable text, clear status/error states, and non-colour-only indicators.
- Both Android and iOS are first-release platforms; platform-specific limits must be surfaced honestly.

## 3. Release architecture and inactive features

The downloaded Flutter application contains Quran study, audio, Azkar, tafsir, hifz, widgets, Firebase, and other features. These modules remain in the repository and are not deleted or broadly commented out.

A release-feature registry controls which modules appear in navigation and can be entered through deep links. Phase 1 exposes only the prayer-times flow and the settings/onboarding required to configure it. Hidden modules must remain buildable but must not be reachable from the release UI. This avoids dead commented code while allowing each module to be promoted in a later phase.

## 4. Information architecture

### Phase 1 navigation

- Home: the daily prayer dashboard.
- Schedule: today plus a date-oriented view of prayer times.
- Settings: location, calculation, adjustments, appearance, and privacy/help.

The initial dashboard contains a prominent next-prayer card, countdown, daily prayer list, location status, date, and a compact route to calculation settings. It must gracefully display loading, no-location, denied-permission, stale-data, and calculation-error states.

## 5. Phased functional requirements

### Phase 0 — Foundation

1. Establish a unique product name, package identifiers, app icon, colour tokens, typography, spacing, and component conventions.
2. Use one adaptive Flutter UI for Android and iOS with responsive phone layouts, dark/light themes, and semantic accessibility labels.
3. Replace any visible Al-Furkan branding before distribution; audit the origin and licence of Quran text, translations, recitations, images, fonts, and icons before each is shipped.
4. Add a release-feature registry; move navigation entries behind it without removing the underlying modules.
5. Ensure launch cannot block indefinitely: surface initialization failures with a safe retry path and never silently clear user data.

### Phase 1 — Prayer Times Core

1. On first launch, explain why location helps and offer: use device location, search/select a city, or enter coordinates manually.
2. Persist the selected location, timezone, calculation method, madhhab, high-latitude rule, and per-prayer minute offsets locally.
3. Calculate Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha for the selected date using a documented prayer-time engine.
4. Offer common calculation methods and clearly describe the selected method. Include a configurable madhhab for Asr and a high-latitude rule.
5. Automatically update the schedule at the local-date boundary and when a user changes location or settings. Cache the most recently valid schedule for offline use and label it if stale.
6. The home dashboard shows the active/next prayer, an accurate countdown, all daily times, selected location, and Gregorian/Hijri dates.
7. Users can open a schedule view to inspect a different date, then return to today.
8. Any unavailable data, denied permission, invalid timezone, or calculation error must give a plain-language recovery action.

### Phase 2 — Prayer Alerts and Athan

1. Enable alerts separately for Fajr, Dhuhr, Asr, Maghrib, and Isha, with optional pre-prayer reminder offsets.
2. Let users select the notification sound, vibration behaviour, and quiet hours within platform capability.
3. Recalculate and reschedule alerts after a relevant setting/location/date change and after device reboot where supported.
4. Clearly state iOS and Android constraints. The app must not promise uninterrupted full Athan playback if the operating system only permits a scheduled notification.
5. Provide a test-alert action and a clear status when notification permission is denied.

### Phase 3 — Daily Practice

1. Add a qibla compass with calibration guidance and a non-sensor bearing fallback.
2. Allow users to mark prayers completed; store a local daily history and show simple weekly progress and streaks.
3. Add curated morning and evening Azkar, with repeat counters and progress that survives app restarts.
4. Consider home-screen widgets only after their data refresh and platform reliability are validated.

### Phase 4 — Quran Essentials

1. Provide Arabic Quran reading with an English translation, last-read position, bookmarks, and surah/ayah navigation.
2. Add basic recitation streaming with play/pause, current ayah, and predictable error/retry behaviour.
3. Add Quran search only after text/translation sources and their licences are confirmed.

### Later phases

Offline audio, multiple reciters, tafsir and translation downloads, word-level study, tajweed, notes, collections, hifz, khatma, reading statistics, widgets, optional cloud sync, and monetisation are deliberately deferred.

## 6. Quality and acceptance requirements

### Accuracy

- With a known location, date, timezone, method, madhhab, and offsets, every displayed time matches the selected prayer engine's output.
- Changing any calculation input visibly refreshes the schedule and next-prayer countdown.
- The schedule works from locally cached settings without a network connection.

### Privacy and permissions

- Location permission is requested only after an explanatory user action.
- Manual location works with no location permission.
- Phase 1 has no account, ads, analytics requirement, or remote personal-data store.

### Reliability

- Launch, time calculation, location lookup, and persistence failures have visible recovery paths.
- Switching timezones/date boundaries does not retain a stale countdown as though it were current.
- Existing inactive modules do not alter Phase 1 startup, navigation, or permissions unexpectedly.

### Experience

- The next prayer and its time remain understandable at a glance in both themes.
- Text supports system font scaling and screen readers.
- No essential status is conveyed only through colour or animation.

## 7. Non-goals for the first build

- User accounts, social/community features, subscriptions, advertising, or online admin content.
- Comprehensive Quran study features or audio downloads.
- Guaranteed background full-Athan playback beyond the permissions and scheduling mechanisms provided by each OS.

## 8. Delivery order

Implement Phase 0 only as the minimum required to safely ship Phase 1. Then build and verify Phase 1 end-to-end on Android and iOS before moving to Phase 2. Each later phase gets a separate requirements refinement, implementation plan, and acceptance pass.
