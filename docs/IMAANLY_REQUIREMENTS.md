# Imaanly — Product Requirements & Development Tracker

**Product direction:** Balanced Islamic Companion — modern, attractive, calm and more advanced than a basic Athan-style app.  
**Branch:** `main`  
**Last tracker update:** 2026-09-06

## Status legend
- ✅ Done
- 🟢 Core done; validation/polish remains
- 🟡 In progress
- ⏳ Planned
- ⏸️ Deferred by product decision

## Overall completion
**~66% feature-complete.** This is a planning estimate, not a build/test percentage. Production readiness is lower until CI, tests, Android build and physical-device validation are clean.

## Product principles
- Free to run/use initially.
- No mandatory sign-in or account.
- No mandatory paid API, backend or cloud service.
- Offline-first for core experiences.
- Local storage for personal progress/preferences.
- Advanced, attractive Material 3 UI; excellent light/dark and RTL support.
- Preserve mature Quran/prayer functionality when extending the app.
- Ads/monetization are deferred until the core free product is stable.

---

# Requirements tracker

## 1. Foundation & Rebrand — 🟢 Core done
- [x] Imaanly branding/package migration started.
- [x] Flutter application foundation.
- [x] Material 3 design foundation.
- [x] Light/dark theme support.
- [x] Local-first architecture.
- [x] No mandatory authentication.
- [x] No mandatory paid service.
- [ ] Final package/import namespace cleanup.
- [ ] Release configuration/audit.

## 2. Home Experience — 🟢 Core done
- [x] Modern Imaanly home experience.
- [x] Current date/Hijri date.
- [x] Location status.
- [x] Next-prayer area and navigation.
- [x] Quran continuation/last-read access.
- [x] Daily Ayah/reflection access.
- [x] Dhikr quick access.
- [x] Qibla quick access.
- [x] Worship-progress summary/dashboard access.
- [x] Islamic Knowledge access.
- [x] Worship Dashboard access.
- [x] Islamic Calendar access.
- [ ] Final information hierarchy/device polish.

## 3. Salah / Prayer — 🟢 Core done
- [x] Prayer calculation foundation.
- [x] Location-based prayer times.
- [x] Next prayer/countdown.
- [x] Prayer timeline.
- [x] Calculation method/Madhab settings.
- [x] Explicit user-controlled prayer completion.
- [x] Local worship activity recording.
- [x] Individual prayer notification controls.
- [x] Athan/reminder configuration foundation.
- [x] Sunnah/Wudu guidance inherited.
- [ ] Android device notification validation.
- [ ] Timezone/DST/edge-case validation.

## 4. Athan & Notifications — 🟢 Core done
- [x] Local prayer notification scheduling.
- [x] Notification preferences/offsets.
- [x] Restoration/reboot infrastructure.
- [ ] Complete physical-device reliability testing.
- [ ] Intelligent context-aware reminders.
- [ ] Notification fatigue controls.

## 5. Qibla — 🟢 Core done
- [x] Qibla direction calculation.
- [x] Compass UI.
- [x] Distance/direction calculation.
- [x] Calibration/permission states foundation.
- [x] Corrected Lahore→Kaaba test range.
- [ ] Physical compass validation on Android devices.
- [ ] Final calibration/onboarding polish.

## 6. Quran — 🟢 Core done
- [x] QCF/Uthmanic rendering.
- [x] Surah index/search.
- [x] Offline Quran content foundation.
- [x] Translations/transliteration.
- [x] Tafsir.
- [x] Audio/reading infrastructure.
- [x] Bookmarks/collections.
- [x] Hifz functionality preserved.
- [x] Surah index visual/lifecycle polish.
- [ ] Final device validation.
- [ ] Deeper worship-goal/history integration.

## 7. Dhikr — 🟢 Core done
- [x] Azkar categories/content.
- [x] Morning/evening discovery.
- [x] Search.
- [x] Attractive responsive UI.
- [x] Counter + haptic interaction.
- [x] Font-size controls.
- [x] Sharing.
- [x] Daily progress persistence.
- [x] Daily goal/progress.
- [x] Streak/history foundation.
- [x] Unified worship activity bridge.
- [ ] Final device validation.
- [ ] Further history/insights polish.

## 8. Unified Worship Activity — 🟢 Core done
- [x] Salah activity model.
- [x] Quran activity model.
- [x] Dhikr activity model.
- [x] Local repository.
- [x] Daily aggregation.
- [x] Idempotent Salah completion.
- [x] Dhikr daily snapshots to prevent double-counting.
- [x] Daily worship summary.
- [x] Unit tests for core calculations.
- [ ] Full Flutter test execution in CI.
- [ ] Historical migration/backfill where needed.

## 9. Worship Dashboard — 🟢 Core done
- [x] Daily worship overview.
- [x] Salah progress.
- [x] Quran progress.
- [x] Dhikr progress.
- [x] Unified activity integration.
- [x] Attractive dashboard cards.
- [x] Goals/progress foundation.
- [ ] Final Home/dashboard UX polish.
- [ ] Historical trends refinement.

## 10. Worship Analytics — 🟢 Core done
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

## 11. Islamic Knowledge — 🟢 Core done
- [x] Knowledge hub.
- [x] Local search.
- [x] Tafsir discovery.
- [x] Quran-topic/saved-content discovery.
- [x] Worship & Adab categories.
- [x] Collections integration.
- [ ] Expand curated educational content.
- [ ] Stronger source attribution UX.
- [ ] Final content review.

## 12. Islamic Calendar — 🟡 In progress
- [x] Gregorian date.
- [x] Hijri date conversion.
- [x] Offline/local calculation.
- [x] Adjustment concept.
- [ ] Important Islamic dates.
- [ ] Month navigation.
- [ ] Event detail cards.
- [ ] Final premium calendar UI.

## 13. Android Widgets — 🟡 In progress
- [x] Widget infrastructure.
- [x] Prayer widget foundation.
- [x] Ayah widget.
- [x] Dhikr widget.
- [x] Background refresh infrastructure.
- [x] Deep-link infrastructure.
- [ ] Final Imaanly widget UX.
- [ ] Widget configuration UX.
- [ ] Physical-device validation.
- [ ] Reboot/background restriction reliability testing.

## 14. Intelligent Notifications — ⏳ Planned
- [ ] Local context-aware reminders.
- [ ] Quran-goal reminders.
- [ ] Dhikr-goal reminders.
- [ ] Streak-risk reminders.
- [ ] Gentle personalized timing.
- [ ] User-controlled notification categories.
- [ ] Notification fatigue limits.
- [ ] No cloud/paid AI required for initial version.

## 15. Personalization — ⏳ Planned
- [ ] Personalized home shortcuts.
- [ ] Appearance preferences.
- [ ] Quran reading preferences.
- [ ] Dhikr preferences.
- [ ] Dashboard preferences.
- [ ] Local-only personalization storage.

## 16. Profile & Settings — 🟡 Existing / expansion required
- [x] Prayer settings.
- [x] Notification settings.
- [x] Location/calculation settings.
- [ ] Unified Imaanly settings experience.
- [ ] Privacy/data controls.
- [ ] Personalization settings.
- [ ] About/version information.
- [ ] Final settings UI modernization.

---

# Explicitly deferred

These must **not** be implemented in the current sequence unless the product decision changes:

- ⏸️ **Hifz improvements** — existing Hifz functionality remains; deeper improvements later.
- ⏸️ **Islamic Places** — nearby mosque/Islamic-place discovery later.
- ⏸️ **Fasting** — dedicated fasting/Ramadan tracking later.

# Future requirements — documented but inactive

- [ ] Ads/monetization.
- [ ] Optional cloud synchronization.
- [ ] Optional account/login.
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

# Production validation checklist

- [ ] `flutter analyze` clean or findings reviewed.
- [ ] `flutter test` passes.
- [ ] Android debug build succeeds.
- [ ] Release APK succeeds.
- [ ] Fresh install test.
- [ ] Upgrade/existing-data test.
- [ ] Offline operation test.
- [ ] Prayer notification test.
- [ ] Qibla physical-device test.
- [ ] Quran rendering test.
- [ ] Dhikr persistence test.
- [ ] Worship aggregation test.
- [ ] Widget/background test.
- [ ] Light/dark review.
- [ ] RTL review.
- [ ] Accessibility review.
- [ ] Permission-denied flows.
- [ ] Battery/background restrictions.

# Development rule

**Every feature/status-changing commit must update this document.**

Each update must record:
1. Requirement status.
2. What changed.
3. Commit SHA.
4. Overall completion estimate when materially changed.
5. Validation limitations.

Pure refactoring commits that do not change requirements may omit an update, but the next feature commit must synchronize the tracker.

# Tracker history

| Date | Commit | Change |
|---|---|---|
| 2026-09-06 | `3178ff3` | Latest known product baseline before tracker synchronization. |
| 2026-09-06 | pending | Canonical tracker synchronized with current repository status; this commit establishes the new tracking rule. |
