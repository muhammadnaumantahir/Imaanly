# Imaanly — Product Requirements & Development Tracker

**Product:** Imaanly — a modern, calm Islamic companion inspired by Athan, but designed to become broader and more advanced over time.  
**Current product rule:** Free to run, no sign-in, no mandatory server/API, offline-first where practical.  
**Future monetization:** Ads may be added later; they are not part of the current core product.  
**Tracker rule:** This document is a living source of truth and MUST be updated in the same commit as every future implementation commit.

## Status legend
- ✅ **DONE** — implemented.
- 🟢 **CORE DONE** — core implementation exists; validation/polish remains.
- 🟡 **PARTIAL** — meaningful implementation exists; feature is incomplete.
- 🔴 **TODO** — not implemented yet.
- ⏸️ **DEFERRED** — intentionally postponed.
- 🧪 **VALIDATION** — implementation exists but needs Flutter/Android/device verification.

---

# 1. Product principles

- [x] Free core application.
- [x] No account/sign-in required for core functionality.
- [x] No mandatory paid API/backend/cloud service.
- [x] Offline-first for core experiences.
- [x] Local persistence for personal progress/preferences.
- [x] Advanced, attractive, modern Material 3 UI.
- [x] Strong Arabic/RTL support.
- [x] Preserve mature inherited functionality rather than unnecessary rewrites.
- [x] Never fabricate worship-completion statistics.
- [ ] Optional advertising — future.
- [ ] Optional cloud synchronization — future.

# 2. Current product completion

**Overall feature completion: ~66%.**

This is a planning estimate based on implemented product requirements, not a test/build percentage. Production readiness is lower until CI, automated tests, Android builds, and physical-device validation are clean.

---

# 3. Requirements tracker

## 3.1 Foundation & Rebrand — 🟢 CORE DONE (~90%)

- [x] Imaanly branding/package direction.
- [x] Flutter application foundation.
- [x] Material 3 foundation.
- [x] Light/dark theme foundation.
- [x] Local storage/Hive foundation.
- [x] Dependency injection foundation.
- [x] Free/no-account architecture.
- [ ] Final package/import namespace cleanup.
- [ ] Final production/release configuration audit.

## 3.2 Home Experience — 🟢 CORE DONE (~85%)

- [x] Modern Imaanly Home experience.
- [x] Current date/Hijri date.
- [x] Location status.
- [x] Next-prayer area/navigation.
- [x] Quran continuation/last-read access.
- [x] Daily Ayah/reflection access.
- [x] Dhikr quick access.
- [x] Qibla quick access.
- [x] Worship progress/dashboard access.
- [x] Islamic Knowledge access.
- [x] Islamic Calendar access.
- [ ] Final information hierarchy/device polish.

## 3.3 Salah / Prayer — 🟢 CORE DONE (~90%)

- [x] Prayer calculation foundation.
- [x] Location-based prayer times.
- [x] Next prayer/countdown.
- [x] Prayer timeline.
- [x] Calculation method/Madhab settings.
- [x] Adjustments/Iqamah settings foundation.
- [x] Explicit user-controlled prayer completion.
- [x] Local worship activity recording.
- [x] Individual prayer notification controls.
- [x] Athan/reminder configuration foundation.
- [x] Existing Sunnah/Wudu guidance preserved.
- [ ] Android device notification validation.
- [ ] Timezone/DST/edge-case validation.

## 3.4 Athan & Notifications — 🟢 CORE DONE (~85%)

- [x] Local prayer notification scheduling.
- [x] Notification preferences/offsets.
- [x] Restoration/reboot infrastructure.
- [ ] Complete physical-device reliability testing.
- [ ] Intelligent context-aware reminders.
- [ ] Notification fatigue controls.

## 3.5 Qibla — 🟢 CORE DONE (~90%)

- [x] Qibla direction calculation.
- [x] Compass UI.
- [x] Distance/direction calculation.
- [x] Calibration/permission states foundation.
- [x] Corrected Lahore→Kaaba geographic test range.
- [ ] Physical compass validation.
- [ ] Final calibration/onboarding polish.
- [ ] Sensor/location failure-state validation.

## 3.6 Quran — 🟢 CORE DONE (~90%)

- [x] QCF/Uthmanic rendering foundation.
- [x] Surah index/search.
- [x] Offline Quran content foundation.
- [x] Translations/transliteration.
- [x] Tafsir.
- [x] Audio/reading infrastructure.
- [x] Bookmarks/collections.
- [x] Existing Hifz functionality preserved.
- [x] Surah index visual/lifecycle polish.
- [ ] Final device/accessibility validation.
- [ ] Deeper reading-goal/history integration.

## 3.7 Dhikr — 🟢 CORE DONE (~90%)

- [x] Azkar categories/content.
- [x] Morning/evening discovery.
- [x] Search.
- [x] Attractive responsive UI.
- [x] Counter + haptic interaction.
- [x] Arabic typography.
- [x] Font-size controls.
- [x] Sharing.
- [x] Daily progress persistence.
- [x] Daily goal/progress.
- [x] Streak/history foundation.
- [x] Unified worship activity bridge.
- [ ] Final device validation.
- [ ] Further history/insights polish.

## 3.8 Unified Worship Activity — 🟢 CORE DONE (~90%)

- [x] Salah activity model.
- [x] Quran activity model.
- [x] Dhikr activity model.
- [x] Local repository.
- [x] Daily aggregation.
- [x] Idempotent Salah completion.
- [x] Dhikr daily snapshots preventing double-counting.
- [x] Daily worship summary.
- [x] Core calculation tests.
- [ ] Full Flutter test execution/verification.
- [ ] Historical migration/backfill strategy.

## 3.9 Worship Dashboard — 🟢 CORE DONE (~90%)

- [x] Daily worship overview.
- [x] Salah progress.
- [x] Quran progress.
- [x] Dhikr progress.
- [x] Unified activity integration.
- [x] Attractive dashboard cards.
- [x] Goals/progress foundation.
- [ ] Final Home/dashboard UX polish.
- [ ] Historical trends refinement.
- [ ] Device validation.

## 3.10 Worship Analytics — 🟢 CORE DONE (~80%)

- [x] Seven-day report.
- [x] Active-day calculation.
- [x] Current streak.
- [x] Salah totals.
- [x] Quran pages.
- [x] Dhikr totals.
- [x] Average worship score.
- [x] Streak interruption handling.
- [x] Empty-week handling.
- [x] Weekly insights UI.
- [x] Tests for weekly insights.
- [ ] Final device/UI validation.
- [ ] Long-term history UX.

## 3.11 Islamic Knowledge — 🟢 CORE DONE (~85%)

- [x] Knowledge Hub.
- [x] Local search.
- [x] Tafsir discovery.
- [x] Quran topic/saved-content discovery.
- [x] Worship & Adab categories.
- [x] Collections integration.
- [ ] Expand curated educational content.
- [ ] Stronger source attribution UX.
- [ ] Final content review.

## 3.12 Islamic Calendar — 🟡 PARTIAL (~50%)

- [x] Gregorian date.
- [x] Hijri date conversion.
- [x] Offline/local calculation.
- [x] Adjustment concept/foundation.
- [ ] Important Islamic dates.
- [ ] Month navigation.
- [ ] Event detail cards.
- [ ] Premium calendar UI.
- [ ] Final validation.

## 3.13 Android Widgets — 🟡 PARTIAL (~65%)

- [x] Widget infrastructure.
- [x] Prayer widget foundation.
- [x] Ayah/Quran widget.
- [x] Dhikr widget.
- [x] Background refresh infrastructure.
- [x] Deep-link infrastructure.
- [ ] Final Imaanly widget UX.
- [ ] Widget configuration UX.
- [ ] Physical-device validation.
- [ ] Reboot/background restriction testing.

## 3.14 Intelligent Local Notifications — 🔴 TODO (0%)

- [ ] Local context-aware decision engine.
- [ ] Quran-goal reminders.
- [ ] Dhikr-goal reminders.
- [ ] Streak-risk reminders.
- [ ] Gentle personalized timing.
- [ ] User-controlled notification categories.
- [ ] Notification fatigue limits.
- [ ] No cloud/paid AI requirement.

## 3.15 Personalization — 🔴 TODO (0%)

- [ ] Personalized Home shortcuts.
- [ ] Appearance preferences.
- [ ] Quran reading preferences.
- [ ] Dhikr preferences.
- [ ] Dashboard preferences.
- [ ] Local-only preference storage.
- [ ] Reset/export preferences.

## 3.16 Profile & Settings — 🟡 PARTIAL (~45%)

- [x] Prayer settings.
- [x] Notification settings.
- [x] Location/calculation settings.
- [ ] Unified Imaanly Settings experience.
- [ ] Privacy/data controls.
- [ ] Personalization settings.
- [ ] Widget settings.
- [ ] About/version information.
- [ ] Final settings UI modernization.

---

# 4. Explicitly deferred by product decision

Do **not** implement these in the current sequence unless explicitly re-approved:

- ⏸️ **Hifz improvements** — existing Hifz functionality remains preserved; deeper improvements later.
- ⏸️ **Islamic Places** — mosque/Islamic-place discovery later.
- ⏸️ **Fasting** — fasting/Ramadan tracking later.

---

# 5. Future requirements — inactive for now

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

---

# 6. Production validation checklist

- [ ] `flutter analyze` clean or findings explicitly reviewed.
- [ ] `flutter test` passes.
- [ ] Android debug build succeeds.
- [ ] Android release APK succeeds.
- [ ] Fresh-install test.
- [ ] Existing-data upgrade test.
- [ ] Offline operation test.
- [ ] Prayer notification/reboot test.
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

---

# 7. Development order

1. **CI/build stabilization** — current stabilization priority.
2. **Complete Islamic Calendar.**
3. **Complete/productize Android Widgets.**
4. **Intelligent Local Notifications.**
5. **Personalization.**
6. **Profile & Settings consolidation.**
7. **Final UI/UX polish.**
8. **Full Android/device validation.**
9. **Release preparation.**
10. Later: Hifz improvements, Islamic Places, Fasting.

---

# 8. Mandatory documentation rule

**Every future feature/status-changing commit MUST update this document in the same commit.**

Each update must:
1. Mark completed requirements.
2. Update PARTIAL/CORE DONE/TODO status.
3. Add newly approved requirements.
4. Keep deferred requirements visible.
5. Update the overall completion estimate when materially changed.
6. Add the commit to the changelog.
7. Record important validation limitations honestly.

Pure refactoring commits that do not change requirements may omit a tracker change, but every feature commit must synchronize it.

---

# 9. Changelog

| Date | Commit / milestone | Result | Overall |
|---|---|---|---:|
| 2026-09-06 | `3178ff3` | Weekly worship insights tests were the latest known baseline before tracker synchronization. | ~66% |
| 2026-09-06 | `7a0261a` | CI analyzer warnings/info made non-fatal so test stage can execute; CI verification remains required. | ~66% |
| 2026-09-06 | Requirements tracker | Canonical living requirements tracker synchronized with current repository state and mandatory future-update rule established. | ~66% |

---

# 10. Engineering rules

- Do not add a paid service when a free/local implementation is sufficient.
- Do not require login for current core functionality.
- Do not fabricate prayer/worship completion.
- Keep worship analytics transparent.
- Prefer small testable domain services over screen-level business logic.
- Preserve stable Quran rendering/audio infrastructure unless there is measurable benefit to changing it.
- UI should be advanced and attractive while remaining calm and worship-focused.
- Do not claim tests/builds pass without actual verification.
