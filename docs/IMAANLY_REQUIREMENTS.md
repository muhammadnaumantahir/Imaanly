# Imaanly — Product Requirements Baseline

**Product direction:** C — Balanced Islamic Companion
**Status:** Baseline v1.0 — development started

## 1. Product vision

Imaanly is a modern, calm Islamic companion that brings the user's daily worship essentials into one experience: Salah, Quran, Dhikr, Qibla, Islamic knowledge, fasting, Hifz and personal worship progress.

The product should feel like a premium daily companion rather than a collection of disconnected utilities or a direct Athan clone.

## 2. Primary navigation

- Home — daily overview and quick actions
- Prayer — prayer times, next prayer, reminders, Sunnah and prayer guidance
- Quran — reading, search, translations, Tafsir, audio, bookmarks and Hifz
- Dhikr — Azkar, counters, routines and progress
- More — Qibla, calendar, fasting, knowledge, settings and future modules

## 3. MVP requirements

### Home
- Show current date and Hijri date.
- Show location status.
- Show next-prayer area and link to the full prayer screen.
- Show Quran continuation / last-read action.
- Show daily Ayah or Islamic reflection.
- Show Dhikr quick action.
- Show Qibla quick action.
- Show a compact worship-progress summary.
- Work in light and dark themes.

### Prayer
- Existing prayer calculation foundation remains the source of truth.
- Prayer times by selected location.
- Next prayer and countdown.
- Individual prayer notification controls.
- Athan/reminder configuration.
- Sunnah prayer and Wudu guidance.

### Quran
- Preserve the existing QCF/Uthmanic rendering foundation.
- Preserve offline translations/Tafsir/audio capabilities.
- Improve discovery, reading continuity and interaction UX.
- Last-read position, bookmarks, notes, collections and highlights.

### Dhikr
- Preserve existing Azkar content.
- Category and detail browsing.
- Counter experience.
- Favorites / routines.
- Progress tracking.

### Qibla
- Existing sensor/location implementation is retained.
- Clear calibration and permission states.
- Fast access from Home and More.

## 4. Product quality requirements

- Offline-first for core Quran and Dhikr experiences.
- Arabic/RTL support must remain first-class.
- Accessibility: scalable text, semantic labels and adequate touch targets.
- Fast startup and graceful failure for permissions/network services.
- No feature should require an account unless the feature genuinely needs sync.
- Avoid excessive notifications; users control notification categories.
- Avoid visual clutter, excessive green, generic mosque imagery and dashboard overload.

## 5. Design direction

**Visual language:** Modern Islamic + Premium + Calm.

- Warm neutrals with restrained sage/olive accents.
- Strong Arabic typography paired with clean Latin typography.
- Rounded cards, subtle elevation and generous spacing.
- Small, purposeful animations.
- Excellent dark mode.
- Consistent iconography and component states.
- Prayer-state visuals may subtly change the Home atmosphere without becoming distracting.

## 6. Architecture direction

Keep the inherited Clean Architecture/BLoC foundation and extend it incrementally.

```text
lib/
  core/
    theme/
    routing/
    localization/
    permissions/
    notifications/
    storage/
    networking/
  features/
    home/
    prayer/
    quran/
    qibla/
    dhikr/
    duas/
    hadith/
    hifz/
    calendar/
    fasting/
    worship/
    content/
    widgets/
    settings/
  shared/
    components/
    animations/
    typography/
```

The current `src/` feature structure is not being deleted in one rewrite. New work should be introduced incrementally and migrated when there is a clear benefit.

## 7. Development phases

1. **Phase 0 — Foundation & rebrand**: Imaanly identity, package cleanup, design tokens, documentation.
2. **Phase 1 — Home experience**: balanced companion dashboard and primary navigation.
3. **Phase 2 — Prayer experience**: next prayer, countdown, reminders and polished prayer UI.
4. **Phase 3 — Qibla**: premium compass/calibration experience.
5. **Phase 4 — Quran experience**: reading continuity, discovery and interaction redesign.
6. **Phase 5 — Audio**: reciter discovery, playback UX, downloads and background controls.
7. **Phase 6 — Dhikr**: counter, routines and worship history.
8. **Phase 7 — Worship dashboard**: daily/weekly/monthly progress without gamifying worship excessively.
9. **Phase 8 — Hifz**: memorization plans, review and progress.
10. **Phase 9 — Islamic calendar & fasting**.
11. **Phase 10 — Islamic knowledge/content**.
12. **Phase 11 — Widgets & intelligent notifications**.
13. **Phase 12 — Personalization and profile**.

## 8. Future requirements — intentionally deferred

These are documented now but **must not be implemented until their phase is explicitly started**.

- AI Islamic assistant.
- AI-assisted Quran study and question answering.
- Voice Quran search.
- Quran pronunciation feedback.
- Personalized Islamic learning paths.
- Offline/on-device AI where practical.
- Family worship features.
- Mosque/community features.
- Islamic courses.
- Zakat/donation tools.
- Wearable integrations (Apple Watch / Wear OS).
- Android Auto / CarPlay experiences.
- Advanced AR Qibla.
- Community content and moderation system.

## 9. Non-goals for the initial release

- Building a social network before the core worship experience is excellent.
- Replacing established Quran text/Tafsir sources with unverified generated content.
- Making AI the center of the product.
- Rewriting stable Quran rendering/audio infrastructure without measurable benefit.

## 10. Definition of done for each phase

A phase is complete only when:

1. Requirements are implemented.
2. Existing functionality has not regressed.
3. Light/dark and RTL states are checked.
4. Relevant tests are added/updated.
5. The app builds successfully for the target platform.
6. The Git history clearly identifies the phase and its scope.
