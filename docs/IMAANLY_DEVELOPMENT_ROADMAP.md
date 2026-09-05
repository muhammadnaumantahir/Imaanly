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
**Status: Completed.**

### Phase 2 — Salah / Prayer Times
**Status: Core work completed; final device validation remains.**

### Phase 3 — Athan / Prayer Notifications
**Status: Core local notification engine and prayer alert UX are implemented; hardening and device validation remain.**

### Phase 4 — Qibla
**Status: Core work completed; final physical-device compass validation remains.**

### Phase 5 — Quran Polish
**Status: Core polish completed; final device/UI validation remains.**

### Phase 6 — Dhikr
**Status: Core attractive Dhikr experience and local daily-progress persistence implemented; final device/UI validation remains.**

### Phase 7 — Islamic Knowledge
- Curated offline-first educational content.
- Clear source attribution.
- Avoid presenting uncertain religious claims as authoritative.
- Calm learning hub reusing existing bundled Quran/Tafsir, Dhikr and saved-collection capabilities.
- Local search across learning sections.

**Status: Learning hub, domain catalog, local search and Home navigation integration implemented; final device validation remains.**

### Phase 8 — Worship Dashboard
- Daily Salah progress.
- Quran reading progress.
- Dhikr progress.
- Fasting and worship statistics as later features.
- Keep the dashboard calm rather than crowded.

**Status: Dashboard foundation implemented. It currently consumes existing local Quran reading statistics and persisted per-category Dhikr progress; Salah completion tracking remains intentionally pending because Prayer Times does not yet record actual completion.**

### Phase 9 — Islamic Calendar
- Local Hijri/Gregorian date display.
- Important Islamic dates using the existing calendar capability/dependency where practical.
- No mandatory network dependency.

**Status: Local Hijri/Gregorian day foundation implemented using the existing `hijri` dependency; important-date browsing remains next.**

### Phase 10 — Home-screen Widgets
- Next prayer widget.
- Prayer countdown/status.
- Ayah/Dhikr quick-glance widgets where platform support permits.
- Reuse the existing local widget update infrastructure.

**Status: Planned.**

### Phase 11 — Intelligent Local Notifications
- Context-aware reminders based on local app state.
- Gentle Quran/Dhikr reminders.
- Avoid notification fatigue.
- Keep all worship notifications local and configurable.

**Status: Planned.**

### Phase 12 — Personalization
- Theme and appearance preferences.
- Home shortcuts.
- Reading and Dhikr preferences.
- Local-only personalization with no account requirement.

**Status: Planned.**

### Phase 13 — Profile & Settings Expansion
- Clear local profile/preferences area.
- Privacy-friendly controls.
- Notification, calculation, appearance and content settings in one coherent experience.

**Status: Planned.**

### Deferred by product decision

The following are intentionally **skipped for now**, not removed from the product plan:

- Hifz improvements
- Islamic Places
- Fasting tools

They can be resumed after the core companion experience is integrated and validated.

## Architecture direction

Use the inherited BLoC + Clean Architecture structure and add small feature/domain services rather than putting calculation/business logic inside widgets.

Prayer scheduling should have a stable domain representation that can be reused by Home, Prayer Times, Prayer Timeline, Notifications and future widgets.

Qibla should keep its mathematical core independent from Flutter widgets so it remains deterministic, testable and offline-first.

The mature `TimeListOfPrayers` remains the source of truth for advanced prayer settings and existing notification/Iqamah/adjustment flows until those responsibilities are deliberately extracted into shared services.

The existing Azkar data remains bundled/local. The new Dhikr presentation layer should build on it rather than introduce a remote content service.

The Islamic Knowledge hub should compose existing local content instead of duplicating religious source material. New educational content must have an identifiable source before it is presented as authoritative.

The Worship Dashboard should aggregate existing local metrics only. Do not invent prayer completion from scheduled prayer times; add explicit completion tracking when the Salah UX supports it.

The Islamic Calendar should use the existing local Hijri dependency first and keep any moon-sighting adjustment clearly distinguishable from calculated dates.

## Free-cost rule

Before adding any dependency or service, ask:

1. Can this run locally on the device?
2. Can an existing open-source dependency solve it?
3. Does it introduce an API key, recurring bill, hosted backend, or account requirement?
4. Does the feature still work offline if the network disappears?

If a paid/cloud dependency is not necessary, do not introduce it.
