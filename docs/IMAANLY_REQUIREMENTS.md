# Imaanly — Product Requirements & Development Tracker

**Product:** Imaanly — a modern, calm Islamic companion inspired by Athan, designed to become broader and more advanced over time.
**Current product rule:** Free to run, no sign-in, no mandatory server/API, offline-first where practical.
**Future monetization:** Ads may be added later; they are not part of the current core product.
**Tracker rule:** This document is the living source of truth and MUST be updated with every future implementation/status-changing commit.

## Status legend
- ✅ DONE — implemented.
- 🟢 CORE DONE — core implementation exists; validation/polish remains.
- 🟡 PARTIAL — meaningful implementation exists; feature is incomplete.
- 🔴 TODO — not implemented yet.
- ⏸️ DEFERRED — intentionally postponed.
- 🧪 VALIDATION — implementation exists but needs Flutter/Android/device verification.

## Overall completion
**~80% feature-complete.** Planning estimate based on product requirements, not a test/build percentage. Production readiness remains lower until CI, automated tests, Android builds and physical-device validation are clean.

## 2. Feature tracker

### 2.1 Foundation & Rebrand — 🟢 CORE DONE (~90%)
- [x] Imaanly branding/package direction.
- [x] Flutter foundation.
- [x] Material 3 foundation.
- [x] Light/dark theme foundation.
- [x] Hive/local storage foundation.
- [x] Dependency injection foundation.
- [x] Free/no-account architecture.
- [ ] Final package/import namespace cleanup.
- [ ] Final production/release configuration audit.

### 2.2 Home Experience — 🟢 CORE DONE (~85%)
- [x] Modern Imaanly Home.
- [x] Gregorian/Hijri date.
- [x] Location status.
- [x] Next-prayer area/navigation.
- [x] Quran continuation/last-read.
- [x] Daily Ayah/reflection access.
- [x] Dhikr quick access.
- [x] Qibla quick access.
- [x] Worship dashboard access.
- [x] Islamic Knowledge access.
- [x] Islamic Calendar access.
- [ ] Final hierarchy/device polish.

### 2.3 Salah / Prayer — 🟢 CORE DONE (~90%)
- [x] Prayer calculation and location-based times.
- [x] Next prayer/countdown.
- [x] Prayer timeline.
- [x] Calculation method/Madhab.
- [x] Adjustments/Iqamah foundation.
- [x] Explicit user-controlled completion.
- [x] Local worship activity recording.
- [x] Individual prayer notification controls.
- [x] Athan/reminder configuration foundation.
- [x] Existing Sunnah/Wudu guidance preserved.
- [ ] Android notification validation.
- [ ] Timezone/DST/edge-case validation.

### 2.4 Athan & Notifications — 🟢 CORE DONE (~92%)
- [x] Local prayer notification scheduling.
- [x] Notification preferences/offsets.
- [x] Restoration/reboot infrastructure.
- [x] Local contextual decision engine.
- [x] Local notification preferences and fatigue limits.
- [x] Concrete Awesome Notifications delivery adapter for contextual decisions.
- [x] Android/iOS background evaluation scheduler via Workmanager.
- [ ] Physical-device reliability testing.

### 2.5 Qibla — 🟢 CORE DONE (~90%)
- [x] Qibla direction calculation.
- [x] Compass UI.
- [x] Distance/direction calculation.
- [x] Calibration/permission foundation.
- [x] Corrected Lahore→Kaaba test range.
- [ ] Physical compass validation.
- [ ] Calibration/onboarding polish.
- [ ] Sensor/location failure validation.

### 2.6 Quran — 🟢 CORE DONE (~90%)
- [x] QCF/Uthmanic rendering.
- [x] Surah index/search.
- [x] Offline Quran content.
- [x] Translation/transliteration.
- [x] Tafsir.
- [x] Audio/reading infrastructure.
- [x] Bookmarks/collections.
- [x] Existing Hifz preserved.
- [x] Surah index visual/lifecycle polish.
- [ ] Final device/accessibility validation.
- [ ] Deeper reading-goal/history integration.

### 2.7 Dhikr — 🟢 CORE DONE (~90%)
- [x] Azkar categories/content.
- [x] Morning/evening discovery.
- [x] Search.
- [x] Responsive UI.
- [x] Counter + haptics.
- [x] Arabic typography.
- [x] Font-size controls.
- [x] Sharing.
- [x] Daily persistence.
- [x] Daily goal/progress.
- [x] Streak/history foundation.
- [x] Unified worship bridge.
- [ ] Device validation.
- [ ] Further history/insights polish.

### 2.8 Unified Worship Activity — 🟢 CORE DONE (~90%)
- [x] Salah/Quran/Dhikr activity models.
- [x] Local repository.
- [x] Daily aggregation.
- [x] Idempotent Salah completion.
- [x] Dhikr daily snapshots preventing double-counting.
- [x] Daily worship summary.
- [x] Core calculation tests.
- [ ] Full Flutter test verification.
- [ ] Historical migration/backfill strategy.

### 2.9 Worship Dashboard — 🟢 CORE DONE (~90%)
- [x] Daily overview.
- [x] Salah/Quran/Dhikr progress.
- [x] Unified integration.
- [x] Dashboard cards.
- [x] Goals/progress foundation.
- [ ] Final Home/dashboard UX polish.
- [ ] Historical trends refinement.
- [ ] Device validation.

### 2.10 Worship Analytics — 🟢 CORE DONE (~80%)
- [x] Seven-day report.
- [x] Active days.
- [x] Current streak.
- [x] Salah totals.
- [x] Quran pages.
- [x] Dhikr totals.
- [x] Average worship score.
- [x] Streak interruption handling.
- [x] Empty-week handling.
- [x] Weekly insights UI.
- [x] Weekly insights tests.
- [ ] Final UI/device validation.
- [ ] Long-term history UX.

### 2.11 Islamic Knowledge — 🟢 CORE DONE (~85%)
- [x] Knowledge Hub.
- [x] Local search.
- [x] Tafsir discovery.
- [x] Quran topic/saved-content discovery.
- [x] Worship & Adab categories.
- [x] Collections integration.
- [ ] Curated content expansion.
- [ ] Stronger source attribution UX.
- [ ] Final content review.

### 2.12 Islamic Calendar — 🟢 CORE DONE (~85%)
- [x] Gregorian date.
- [x] Hijri conversion.
- [x] Offline/local calculation.
- [x] Adjustment foundation.
- [x] Important Islamic dates.
- [x] Month navigation.
- [x] Event detail cards.
- [x] Premium calendar UI.
- [ ] Final validation.

### 2.13 Android Widgets — 🟡 PARTIAL (~65%)
- [x] Widget infrastructure.
- [x] Prayer widget foundation.
- [x] Ayah/Quran widget.
- [x] Dhikr widget.
- [x] Background refresh infrastructure.
- [x] Deep links.
- [ ] Final Imaanly widget UX.
- [ ] Widget configuration UX.
- [ ] Physical-device validation.
- [ ] Reboot/background restriction testing.

### 2.14 Intelligent Local Notifications — 🟢 CORE DONE (~82%)
- [x] Local context-aware decision engine.
- [x] Quran-goal reminders.
- [x] Dhikr-goal reminders.
- [x] Streak-risk reminders.
- [ ] Gentle personalized timing.
- [x] User-controlled categories.
- [x] Notification fatigue limits.
- [x] No cloud/paid AI requirement.
- [x] Platform notification delivery adapter.
- [x] Background periodic context evaluation.
- [ ] Physical-device/background restriction validation.

### 2.15 Personalization — 🟡 PARTIAL (~45%)
- [x] Personalized Home shortcut preferences model.
- [x] Appearance preference model.
- [x] Quran reading preference model.
- [x] Dhikr preference model.
- [x] Dashboard preference model.
- [x] Local-only preference storage.
- [x] Reset/export/import preference repository.
- [x] Personalization settings UI.
- [x] Appearance preference connected to ThemeCubit.
- [ ] Connect Home shortcut preferences to Home UI.
- [ ] Connect Quran preferences to reader settings.
- [ ] Connect Dhikr preference to daily goal UI.
- [ ] Connect dashboard preference to dashboard UI.

### 2.16 Profile & Settings — 🟡 PARTIAL (~55%)
- [x] Prayer settings.
- [x] Notification settings.
- [x] Location/calculation settings.
- [x] Personalization settings entry point.
- [ ] Unified Imaanly Settings.
- [ ] Privacy/data controls.
- [ ] Widget settings.
- [ ] About/version information.
- [ ] Final settings UI modernization.

## 3. Explicitly deferred
- ⏸️ Hifz improvements — existing functionality remains preserved.
- ⏸️ Islamic Places — later.
- ⏸️ Fasting — later.

## 4. Future requirements — inactive
- [ ] Ads/monetization after core stabilization.
- [ ] Optional account/cloud sync.
- [ ] AI Islamic assistant.
- [ ] AI-assisted Quran study/Q&A.
- [ ] Voice Quran search.
- [ ] Pronunciation feedback.
- [ ] Personalized Islamic learning paths.
- [ ] Family worship features.
- [ ] Community/mosque features.
- [ ] Islamic courses.
- [ ] Zakat/donation tools.
- [ ] Wearables.
- [ ] Android Auto/CarPlay.
- [ ] Advanced AR Qibla.

## 5. Production validation checklist
- [ ] `flutter analyze` clean or findings explicitly reviewed.
- [ ] `flutter test` passes.
- [ ] Android debug build succeeds.
- [ ] Android release APK succeeds.
- [ ] Fresh-install test.
- [ ] Existing-data upgrade test.
- [ ] Offline operation test.
- [ ] Prayer notification/reboot test.
- [ ] Contextual background notification test.
- [ ] Qibla physical-device test.
- [ ] Quran rendering test.
- [ ] Dhikr persistence test.
- [ ] Worship aggregation test.
- [ ] Widget/background test.
- [ ] Light/dark review.
- [ ] RTL/Arabic review.
- [ ] Accessibility review.
- [ ] Permission-denied flows.
- [ ] Battery/background restriction testing.

## 6. Development order
1. CI/build stabilization.
2. Complete Islamic Calendar.
3. Complete/productize Android Widgets.
4. Intelligent Local Notifications.
5. Personalization.
6. Profile & Settings consolidation.
7. Final UI/UX polish.
8. Full Android/device validation.
9. Release preparation.
10. Later: Hifz improvements, Islamic Places, Fasting.

## 7. Mandatory documentation rule
Every future feature/status-changing commit MUST update this document in the same commit. Updates must mark requirements, update status/percentages, retain deferred items, update the changelog, and record validation limitations honestly.

## 8. Changelog
| Date | Commit / milestone | Result | Overall |
|---|---|---|---:|
| 2026-09-07 | Personalization settings UI | Added a dedicated local-only personalization settings page covering appearance, Quran preferences, Dhikr goal, Home shortcut selection, dashboard compact mode and reset; exposed it from the main Settings page and connected appearance changes to ThemeCubit. Remaining work is wiring these preferences into each consuming feature. | ~80% |
| 2026-09-07 | Contextual scheduler/coordinator contract fix | Aligned the background Workmanager integration with the coordinator's injectable preferences/delivery API, preventing the scheduler from calling a stale method signature. No feature-scope percentage change; CI/device validation remains required. | ~78% |
| 2026-09-07 | Personalization foundation | Added a local-only personalization model/repository with Home shortcuts, appearance, Quran, Dhikr and dashboard preferences plus reset/export/import support and tests. UI wiring remains. | ~78% |
| 2026-09-07 | Contextual background scheduler | Added a Workmanager periodic task that evaluates local worship activity in the background and routes eligible Quran/Dhikr/streak decisions through the local notification delivery adapter. Physical-device/background validation remains. | ~76% |
| 2026-09-07 | Contextual notification delivery | Connected the local smart-notification decision output to the existing Awesome Notifications infrastructure with a dedicated contextual channel and stable category IDs. Background automatic evaluation remained. | ~75% |
| 2026-09-07 | Notification policy phase | Added local category controls, overnight quiet hours, daily notification cap, Quran/Dhikr goal reminders, streak-risk detection, and a persistent once-per-day coordinator. | ~74% |
| 2026-09-07 | `0530545` | Added tests for the local contextual notification planner; direct Flutter test execution remains pending. | ~71% |
| 2026-09-07 | `f7a8551` | Added the first Intelligent Local Notifications decision engine: nearby-prayer priority, Quran/Dhikr fallbacks, and conservative silent behavior. | ~71% |
| 2026-09-07 | `3169e4c` | Fixed CI prayer schedule tests to assert Imaanly's canonical `Prayer` enum instead of the separate `adhan_dart` enum; CI previously reported 150 passed / 2 failed. | ~71% |
| 2026-09-07 | Calendar CI follow-up | Fixed the stale Islamic Calendar day model test after CI reported the newly-required `isCurrentMonth` argument. | ~71% |
| 2026-09-07 | Islamic Calendar phase | Added offline Hijri calendar service, important Islamic dates, month grid/navigation, today card, event cards, and tests. Physical/device validation remains. | ~71% |
| 2026-09-07 | CI stabilization | Root cause found: `simple_icons` 14.6.1 is incompatible with Flutter 3.47/Dart 3.13. Test suite also exposed asynchronous test races and one invalid theme expectation. Fixes are being applied; CI verification remains required. | ~66% |
| 2026-09-06 | `3178ff3` | Weekly worship insights tests added. | ~66% |
| 2026-09-06 | `7a0261a` | Analyzer warnings/info made non-fatal so tests execute. | ~66% |
| 2026-09-06 | Requirements tracker | Canonical living tracker established. | ~66% |

## 9. Engineering rules
- Prefer free/local implementations when sufficient.
- Do not require login for current core functionality.
- Do not fabricate worship completion.
- Keep worship analytics transparent.
- Prefer small testable domain services.
- Preserve stable Quran rendering/audio infrastructure.
- UI should be advanced, attractive, calm and worship-focused.
- Do not claim tests/builds pass without actual verification.
