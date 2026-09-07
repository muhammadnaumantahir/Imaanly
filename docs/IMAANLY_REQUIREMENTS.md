# Imaanly — Product Requirements & Development Tracker

**Product:** Imaanly — a modern, calm Islamic companion inspired by Athan.
**Product rule:** Free, no sign-in, no mandatory server/API, offline-first where practical.
**Tracker rule:** This document is the living source of truth and MUST be updated with every future implementation/status-changing commit.

## Overall completion
**~83% feature-complete.** Planning estimate based on product requirements, not a test/build percentage. Production readiness remains lower until CI, automated tests, Android builds and physical-device validation are clean.

## Feature tracker

### Foundation & Rebrand — 🟢 CORE DONE (~90%)
- [x] Imaanly branding/package direction, Flutter/Material 3 foundation, local storage, DI and free/no-account architecture.
- [ ] Final package/import namespace cleanup.
- [ ] Final production/release configuration audit.

### Home Experience — 🟢 CORE DONE (~92%)
- [x] Modern Home, dates, location, next prayer, Quran continuation, reflection, Dhikr/Qibla access, dashboard and discovery.
- [x] Home shortcut personalization is now consumed reactively by Quick Actions and Quran continuation.
- [ ] Final hierarchy/device polish.

### Salah / Prayer — 🟢 CORE DONE (~90%)
- [x] Prayer calculation/location, next-prayer countdown, timeline, Madhab/calculation settings, completion tracking and local notifications.
- [ ] Android notification validation.
- [ ] Timezone/DST/edge-case validation.

### Athan & Notifications — 🟢 CORE DONE (~92%)
- [x] Local scheduling, preferences/offsets, reboot restoration, contextual decision engine, fatigue controls, delivery adapter and Workmanager background evaluation.
- [ ] Physical-device reliability testing.

### Qibla — 🟢 CORE DONE (~90%)
- [x] Direction calculation, compass UI, distance, calibration/permission foundation and Lahore→Kaaba test coverage.
- [ ] Physical compass/sensor validation and calibration polish.

### Quran — 🟢 CORE DONE (~90%)
- [x] Uthmanic/QCF rendering, index/search, offline content, translation/transliteration, Tafsir, audio, bookmarks and Hifz preservation.
- [x] Added a dedicated bridge component mapping personalization Quran-script choices to the unified Quran font settings.
- [ ] Wire the bridge into the app shell and consume translation visibility preference in the reader.
- [ ] Final device/accessibility validation and deeper reading-goal/history integration.

### Dhikr — 🟢 CORE DONE (~92%)
- [x] Categories/content, search, responsive UI, counter/haptics, Arabic typography, sharing, persistence, streak/history, unified worship bridge and goals.
- [x] Personalization daily-goal preference is stored and available centrally.
- [ ] Wire the preference into all Dhikr goal/progress consumers.
- [ ] Device validation and further history/insights polish.

### Unified Worship Activity — 🟢 CORE DONE (~90%)
- [x] Salah/Quran/Dhikr models, local repository, daily aggregation, idempotent completion, Dhikr snapshots and tests.
- [ ] Full Flutter test verification and migration/backfill strategy.

### Worship Dashboard — 🟢 CORE DONE (~94%)
- [x] Daily overview, Salah/Quran/Dhikr progress, goals, analytics and unified integration.
- [x] Dashboard compact personalization changes the dashboard presentation and secondary cards.
- [ ] Final Home/dashboard UX polish, long-term trends and device validation.

### Worship Analytics — 🟢 CORE DONE (~80%)
- [x] Seven-day report, active days, streaks, Salah/Quran/Dhikr totals, score, interruption/empty-week handling, insights UI/tests.
- [ ] Final UI/device validation and long-term history UX.

### Islamic Knowledge — 🟢 CORE DONE (~85%)
- [x] Knowledge Hub, local search, Tafsir/Quran discovery, Worship/Adab categories and collections.
- [ ] Content expansion, stronger source attribution and final content review.

### Islamic Calendar — 🟢 CORE DONE (~85%)
- [x] Gregorian/Hijri conversion, offline calculation, adjustment, important dates, month navigation, event cards and polished UI.
- [ ] Final validation.

### Android Widgets — 🟡 PARTIAL (~65%)
- [x] Infrastructure, prayer/Ayah/Dhikr widgets, background refresh and deep links.
- [ ] Final widget UX/configuration and physical-device/background/reboot validation.

### Intelligent Local Notifications — 🟢 CORE DONE (~82%)
- [x] Context-aware local engine, Quran/Dhikr/streak reminders, category controls, quiet hours, fatigue limits, delivery adapter and periodic background evaluation.
- [ ] Gentle personalized timing refinement and physical-device/background restriction validation.

### Personalization — 🟢 CORE DONE (~78%)
- [x] Local model/repository, reset/export/import foundation, settings UI, appearance connection, reactive personalization Cubit.
- [x] Home shortcut preferences consumed by Home.
- [x] Dashboard compact preference consumed by Worship Dashboard.
- [x] Personalization state is shared app-wide through DI and updates reactively where integrated.
- [x] Quran-script bridge component created for unified reader settings.
- [ ] Wire Quran bridge into the app shell and connect translation visibility.
- [ ] Connect Dhikr goal preference to all Dhikr goal/progress consumers.

### Profile & Settings — 🟡 PARTIAL (~60%)
- [x] Prayer, notification, location/calculation and personalization settings entry points.
- [ ] Unified Imaanly Settings, privacy/data controls, widget settings, About/version information and final modernization.

## Explicitly deferred
- ⏸️ Hifz improvements — existing functionality remains preserved.
- ⏸️ Islamic Places — later.
- ⏸️ Fasting — later.

## Future requirements — inactive
- [ ] Ads/monetization after core stabilization.
- [ ] Optional account/cloud sync.
- [ ] AI Islamic assistant / AI Quran study/Q&A.
- [ ] Voice Quran search / pronunciation feedback.
- [ ] Personalized Islamic learning paths.
- [ ] Family/community/mosque features.
- [ ] Islamic courses, Zakat/donation tools, wearables, Android Auto/CarPlay, advanced AR Qibla.

## Production validation checklist
- [ ] `flutter analyze` clean or findings explicitly reviewed.
- [ ] `flutter test` passes.
- [ ] Android debug build succeeds.
- [ ] Android release APK succeeds.
- [ ] Fresh-install and existing-data upgrade tests.
- [ ] Offline operation.
- [ ] Prayer/contextual notification and reboot tests.
- [ ] Qibla physical-device test.
- [ ] Quran rendering and Dhikr persistence tests.
- [ ] Worship aggregation and widget/background tests.
- [ ] Light/dark, RTL/Arabic and accessibility review.
- [ ] Permission-denied and battery/background restriction flows.

## Development order
1. CI/build stabilization.
2. Productize Android Widgets.
3. Finish Intelligent Local Notifications validation/timing.
4. Finish Personalization consumer wiring.
5. Consolidate Profile & Settings.
6. Final UI/UX polish.
7. Full Android/device validation.
8. Release preparation.
9. Later: Hifz improvements, Islamic Places, Fasting.

## Mandatory documentation rule
Every future feature/status-changing commit MUST update this document in the same commit, mark requirements, update percentages, retain deferred items, update the changelog and record validation limitations honestly.

## Changelog
| Date | Commit / milestone | Result | Overall |
|---|---|---|---:|
| 2026-09-07 | Quran personalization bridge | Added a reusable bridge component mapping the app-level Quran script preference to the unified Quran font-family settings. App-shell integration remains next. | ~83% |
| 2026-09-07 | Personalization consumer wiring | Added a shared PersonalizationCubit through DI; Home shortcut choices now drive Quick Actions/Quran continuation and Worship Dashboard compact mode changes the dashboard layout. Added Cubit persistence/reset tests. | ~83% |
| 2026-09-07 | Personalization settings UI | Added local-only settings for appearance, Quran preferences, Dhikr goal, Home shortcuts, dashboard compact mode and reset; appearance is connected to ThemeCubit. | ~80% |
| 2026-09-07 | Contextual scheduler/coordinator contract fix | Aligned Workmanager background integration with the coordinator API. | ~78% |
| 2026-09-07 | Personalization foundation | Added local personalization model/repository with reset/export/import support and tests. | ~78% |
| 2026-09-07 | Contextual background scheduler | Added periodic local background evaluation for Quran/Dhikr/streak decisions. | ~76% |
| 2026-09-07 | Contextual notification delivery | Connected smart-notification decisions to Awesome Notifications. | ~75% |
| 2026-09-07 | Notification policy phase | Added category controls, quiet hours, daily cap and reminder policies. | ~74% |
| 2026-09-07 | Intelligent Local Notifications | Added first context-aware local notification decision engine. | ~71% |
| 2026-09-07 | Islamic Calendar phase | Added offline Hijri calendar, dates, month navigation and event UI/tests. | ~71% |
| 2026-09-07 | CI stabilization | Identified Flutter/Dart compatibility and asynchronous test issues; validation remains ongoing. | ~66% |
| 2026-09-06 | Requirements tracker | Canonical living tracker established. | ~66% |

## Engineering rules
- Prefer free/local implementations when sufficient.
- Do not require login for current core functionality.
- Do not fabricate worship completion.
- Keep worship analytics transparent.
- Prefer small testable domain services.
- Preserve stable Quran rendering/audio infrastructure.
- UI should be advanced, attractive, calm and worship-focused.
- Do not claim tests/builds pass without actual verification.
