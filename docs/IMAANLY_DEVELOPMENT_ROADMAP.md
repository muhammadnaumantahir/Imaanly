# Imaanly Development Roadmap

## Product

**Imaanly — your intelligent daily Islamic companion.**

The first release should feel simple and dependable like a dedicated Salah/Athan app, then grow into a balanced Islamic companion without overwhelming the user.

## Locked product principles

- Free to run and develop initially.
- No mandatory paid API, server, subscription, login, or account system.
- Local-first and offline-capable wherever practical.
- Prayer calculations happen on-device.
- Qibla calculations happen on-device.
- Quran, Dhikr and core Islamic resources should remain usable offline when bundled or already downloaded.
- Network access is optional and must not be required for core worship flows.
- Ads are disabled initially.
- If monetization is introduced later, ads must never interrupt Quran reading, Salah/Athan, Dhikr, Qibla, or other worship actions.
- Preserve mature inherited functionality instead of replacing working subsystems unnecessarily.
- Prefer existing open-source Flutter packages and local storage over paid infrastructure.
- Worship interactions should feel calm, tactile and premium rather than gamified or distracting.

## Development phases

### Phase 1 — Foundation & Rebranding

- Imaanly product identity and home experience.
- Modern Islamic/premium/calm Material 3 styling.
- Rounded cards, strong typography, dark-mode support and responsive layouts.
- Core shortcuts: Salah, Quran, Dhikr and Qibla.
- Keep inherited Quran/prayer functionality intact.

**Status: Completed.**

### Phase 2 — Salah / Prayer Times

- Preserve existing prayer calculation, adjustment, Iqamah and notification behavior.
- Add a focused Prayer Timeline presentation.
- Show current prayer, next prayer, live countdown and five daily prayers.
- Show sunrise separately.
- Correctly handle after-Isha → following-day Fajr.
- Reuse the user's selected calculation method and Madhab in the timeline.
- Keep a canonical prayer schedule domain model for future Home, notifications and widgets.

**Status: Core work completed; final device validation remains.**

### Phase 3 — Athan / Prayer Notifications

- Make prayer alerts easy to understand and configure.
- Per-prayer enable/disable.
- Optional lead time before prayer.
- Reliable local scheduling.
- Permission-aware onboarding.
- Fajr-specific worship actions where appropriate.
- Reschedule after location/calculation changes.
- Avoid any cloud notification dependency.
- Initialize notification channels before prayer scheduling.
- Restore saved notification schedules without requiring the user to reopen settings.

**Status: Core local notification engine and prayer alert UX are implemented; hardening and device validation remain.**

### Phase 4 — Qibla

- Polished Qibla screen.
- On-device compass/direction.
- Calibration guidance.
- Offline operation.
- Pure domain calculations for normalization, shortest-turn guidance and great-circle distance to the Kaaba.
- Unit coverage for the core Qibla math.

**Status: Core work completed; final physical-device compass validation remains.**

### Phase 5 — Quran Polish

- Keep the mature QCF/Uthmanic reader.
- Improve discovery from Home.
- Preserve audio, Tafsir, translations, bookmarks and Hifz functionality.
- Improve Surah discovery with a responsive card-based index and lifecycle-safe search.

**Status: Core polish completed; final device/UI validation remains.**

### Phase 6 — Dhikr

- Simple offline Dhikr experience.
- Categories and counters.
- Daily progress stored locally.
- Fast search and featured morning/evening access.
- Tactile counting with haptic feedback.
- Font-size personalization and share/image actions in the existing detail experience.

**Status: Core attractive Dhikr experience implemented; daily-progress persistence and final device validation remain.**

### Phase 7 — Islamic Knowledge

- Curated offline-first educational content.
- Clear source attribution.
- Avoid presenting uncertain religious claims as authoritative.

### Phase 8 — Worship Dashboard

- Daily Salah progress.
- Quran reading progress.
- Dhikr progress.
- Fasting and worship statistics as later features.
- Keep the dashboard calm rather than crowded.

### Later phases

- Hifz improvements
- Islamic calendar
- Fasting tools
- Islamic places
- Home-screen widgets
- Intelligent local notifications
- Personalization
- Optional profile/settings expansion

## Architecture direction

Use the inherited BLoC + Clean Architecture structure and add small feature/domain services rather than putting calculation/business logic inside widgets.

Prayer scheduling should have a stable domain representation that can be reused by:

- Home
- Prayer Times
- Prayer Timeline
- Notifications
- Future widgets

Qibla should keep its mathematical core independent from Flutter widgets so it remains deterministic, testable and offline-first.

The mature `TimeListOfPrayers` remains the source of truth for advanced prayer settings and existing notification/Iqamah/adjustment flows until those responsibilities are deliberately extracted into shared services.

The existing Azkar data remains bundled/local. The new Dhikr presentation layer should build on it rather than introduce a remote content service.

## Free-cost rule

Before adding any dependency or service, ask:

1. Can this run locally on the device?
2. Can an existing open-source dependency solve it?
3. Does it introduce an API key, recurring bill, hosted backend, or account requirement?
4. Does the feature still work offline if the network disappears?

If a paid/cloud dependency is not necessary, do not introduce it.
