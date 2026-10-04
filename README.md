<div align="center">

<img src="docs/branding/imaanly-icon.png" width="132" alt="Imaanly app icon" />

# Imaanly

**A beautiful, offline-first Islamic companion for Quran, Salah, Qibla, Dhikr and daily worship — built with Flutter.**

[![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white&style=for-the-badge)](https://developer.android.com)
[![Architecture](https://img.shields.io/badge/Architecture-BLoC_%2B_Clean-0F7A5C?style=for-the-badge)](#architecture)
[![License](https://img.shields.io/badge/License-Apache_2.0_%2B_Waqf_condition-C9A24B?style=for-the-badge)](#license--waqf-condition)

</div>

---

## About

Imaanly is a cross-platform Flutter app for daily Islamic life. It brings an interactive Uthmanic Mushaf, a deep ayah library (tafsir, translation, grammar, morphology, qira'at), accurate prayer times, a Qibla compass, azkar, a digital tasbih and personal goals into one calm, modern interface in deep emerald and gold.

It is designed for **daily reading, study, memorization and reflection**, works largely **without internet**, and needs **no API keys** to run.

### Why Imaanly?

- **More than text and audio** — QCF Uthmanic Mushaf, word-level ayah analysis and a full resource manager.
- **Offline-first** — core features run from local storage (`hive_ce`) and downloaded resources.
- **Huge resource library** — 60+ tafsir books, 200+ translations in 50+ languages and 50+ reciters with multiple riwayat.
- **Designed to be used every day** — prayer countdown with a time-of-day sky, verse of the day, tasbih, goals and widgets.
- **Clean, testable code** — BLoC, Clean Architecture and dependency injection with GetIt.

---

## Screenshots

> Screenshots of the redesigned interface will be added to `docs/screenshots/`. The app icon and splash artwork are below.

<p align="center">
  <img src="docs/branding/imaanly-icon.png" width="22%" alt="App icon" />
  &nbsp;&nbsp;
  <img src="docs/branding/imaanly-splash.png" width="22%" alt="Splash screen" />
</p>

<!--
Suggested screenshots (phone, light and dark):
home.png · prayer-times.png · qibla.png · tasbih.png · azkar.png · mushaf.png · ayah-library.png · explore.png
Then reference them here, e.g. <img src="docs/screenshots/home.png" width="22%" />
-->

---

## Features

### Home
- **Next-prayer hero** with a live countdown, progress bar, Hijri date and a sky that changes with the upcoming prayer (dawn, midday, afternoon, sunset, night with stars) over a mosque skyline.
- **Today's prayers** timeline with the next prayer highlighted and passed prayers checked.
- **Verse of the Day** — a rotating well-known ayah, shown with its reference; tap to enlarge, copy or open the Quran.
- **Quick access** to Quran, Qibla, Tasbih and Azkar.
- **Coming up** — countdown to the next major Islamic date (Islamic New Year, Ashura, Ramadan, Eid al-Fitr, Arafah, Eid al-Adha). Dates follow the calculated Hijri calendar, so local moon sighting may differ by a day.

### Quran and Mushaf
- **Interactive QCF Mushaf** in Uthmanic script with a print-like feel (604 pages).
- **Three layouts**: single page, double page and continuous scroll.
- **Six Quran fonts** plus plain Uthmani, colored **tajweed** and IndoPak text styles.
- **Night reading mode** with warm amber tones and optional automatic activation at sunset.
- **Smart navigation**: surah, juz, hizb, rub, page and ayah jumps; fast search with highlighted results; last-read position is remembered.
- **Ayah-by-ayah mode**, highlighting, notes, favorites and custom collections.
- **Hifz (memorization) mode** with three hiding levels (visible, blurred, hidden), tap-to-reveal, a test mode, progress tracking and repeat.

### Ayah Library
Open any ayah to study it in depth, with tabs for:
- **Translation**, including word-by-word translation
- **I'rab** (grammatical analysis)
- **Morphology** and word roots
- **Qira'at** with differences between readings
- **Mutashabihat** (similar ayahs)
- **Topics**
- **Latin transliteration** for non-Arabic readers

Share an ayah as text or as a customizable, designed image.

### Audio
- **50+ reciters** with multiple riwayat (Hafs, Warsh, Qalun and more).
- **Word-by-word highlighting** while audio plays, and single-word playback.
- **Smart repeat** for an ayah, a range or a whole surah, plus listening to a custom ayah range.
- **Speed control**, background playback with a notification, and a **sleep timer**.
- **Offline player**: download surahs, manage storage and build **custom playlists**.

### Prayer, Qibla and Worship
- **Accurate prayer times** from your location with several calculation methods (default **Karachi, Hanafi Asr**) and adjustable adhan and iqama timing.
- **Qibla compass** with a gold-ringed dial, distance to the Kaaba, calibration help and a glow when you are aligned.
- **Digital Tasbih** with six dhikr, targets of 33, 99, 100 or none, round counting, vibration feedback, daily and all-time totals, undo and reset.
- **Azkar** — morning, evening, sleep, prayer and more, each with a ring-style counter and references.
- **Sunnah guides** for prayer and wudu with evidence and scholars' statements.
- **Islamic calendar**, **prayer tracker**, **fasting tools**, **Zakat calculator**, **99 Names of Allah** and a **Hajj & Umrah** guide.
- **Daily goals**, **Khatma** planning, reading statistics and a worship dashboard.

### Notifications and Widgets
- Prayer alerts, Khatma and daily wird reminders, morning and evening azkar reminders, and Ayah of the Day, all individually configurable.
- **Android home-screen widgets**: Ayah of the Day, Prayer times and Word, with live preview and customization (fonts, colors, themes).

### Resources
- **Tafsir, translations and word data** downloaded on demand, with sizes shown, progress tracking, storage management and automatic fallback sources.
- Multiple tafsirs or translations can be enabled at once.

---

## What's New in the Redesign

- **New identity**: emerald-and-gold palette, new app icon and splash screen, and the **Poppins** typeface throughout.
- **English interface** across all screens, with Quran text and supplications kept in Arabic.
- **Time-of-day hero**, entrance animations, soft bordered cards, rounded navigation and consistent hero cards across Explore, Goals, Analytics and the dashboard.
- **New features**: Digital Tasbih, Verse of the Day, Islamic-date countdown, Qibla alignment glow.
- **Smarter defaults**: device location with Karachi method and Hanafi Asr, and widget prayer times that follow the method chosen in the app.

---

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter 3.x, Dart 3.10+ |
| State management | `flutter_bloc` (BLoC / Cubit) |
| Dependency injection | `get_it` |
| Local storage | `hive_ce`, `shared_preferences` |
| Quran rendering | `qcf_quran` (customized package in `packages/`) |
| Audio | `just_audio` with background playback |
| Prayer times | `adhan_dart` and `hijri` |
| Qibla | `flutter_compass_v2` (patched copy in `packages/`) and `geolocator` |
| Notifications | `awesome_notifications` |
| Home widgets | `home_widget` and `workmanager` |
| UI motion | `flutter_animate` |

## Architecture

The app follows **Clean Architecture** with BLoC for state management:

- **Presentation** — screens, widgets and Bloc/Cubit.
- **Domain** — use cases and entities, independent of Flutter.
- **Data** — repositories, data sources (local, assets, downloads) and models.

```
lib/
├── features/        # Home, Tasbih, Prayer, Goals, Calendar, Sunnah, Analytics, ...
├── src/
│   ├── screen/      # Quran, Mushaf, Qibla, Azkar, Settings, Search, ...
│   ├── theme/       # AppColors, AppTheme, AppFonts, shared widgets (HeroCard, SoftCard)
│   ├── widget/      # Reusable widgets (audio, sharing, ...)
│   └── core/        # Services, audio, settings
└── l10n/            # Localization files
packages/            # Customized qcf_quran and compass packages
```

Design tokens live in `lib/src/theme/app_colors.dart` and the typeface in `lib/src/theme/app_fonts.dart`, so the look of the whole app can be changed from one place.

---

## Getting Started

### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) 3.x with Dart `^3.10`
- Android Studio or VS Code with the Flutter extension
- An Android device or emulator

### Run

```bash
git clone https://github.com/muhammadnaumantahir/Imaanly.git
cd Imaanly
flutter pub get
flutter run
```

No server setup or API keys are required for the first run.

### Regenerate app icon and splash screen

```bash
dart run icons_launcher:create
dart run flutter_native_splash:create
```

The splash artwork is `assets/img/splash_logo.png`, and the icon source is `assets/img/Quran_Logo_v3.png`.

### Quality checks

```bash
flutter analyze
flutter test
```

---

## Data Sources

- **Tafsir and translations**: [Quranic Universal Library](https://github.com/quran/quran.com-api)
- **Recitations**: [EveryAyah.com](https://everyayah.com) and [Quran.com](https://quran.com)
- **Quran metadata**: [Tanzil Project](https://tanzil.net)

## Contributing

Contributions are welcome — bug fixes, translations, design polish and tests. Please open an issue to discuss larger changes first, and keep the Waqf condition below in mind: contributions must keep the project free for everyone.

---

## Credits and Acknowledgments

Imaanly is built on the work of several open-source developers:

1. **Original application** — developed by **IDRISIUM Corp** (engineer **Idris Ghamid**), [github.com/IDRISIUM](https://github.com/IDRISIUM). Original repository: [IDRISIUMCorp/imaanly-quran-flutter-app](https://github.com/IDRISIUMCorp/imaanly-quran-flutter-app).
2. **Uthmanic rendering** — the core [qcf_quran](https://github.com/m4hmoud-atef/qcf_quran) library by **Mahmoud Atef**, deeply reworked by Idris Ghamid in [qcf_quran_with_update](https://github.com/idris-ghamid/qcf_quran_with_update), adding the `QcfThemeData` system for dynamic light and dark colors, responsive typography, and a fix for diacritic clipping.
3. **Foundations** — the reciter database, tafsir and translation structure, and the prayer-time engine build on [al_quran_v3](https://github.com/IsmailHosenIsmailJames/al_quran_v3) by **Ismail Hosen**.
4. **Quranic resources** — Quranic Universal Library, EveryAyah.com, Quran.com and the Tanzil Project (see above).
5. **Redesign and maintenance** — maintained by [Muhammad Nauman Tahir](https://github.com/muhammadnaumantahir): the emerald and gold interface, English localization, Tasbih, Verse of the Day and related improvements.

---

## License and Waqf Condition

This project is released under the **Apache License 2.0**, together with a **Waqf (endowment) condition** set by the original developers:

> The application and its complete source code are offered as **ongoing charity (sadaqah jariyah)** for the sake of Allah, on behalf of the lead developer **Idris Ghamid** and **IDRISIUM Corp**.
>
> **It is strictly prohibited, under any circumstances, to sell this code, or to publish any application built on it for profit, closed commercial use, or with profit-making advertising. All copies must remain 100% free for Muslims, and the original source and developer must be credited.**

See the [LICENSE](LICENSE) file for the license text.

---

<div align="center">

*"Indeed, it is We who sent down the Reminder, and indeed We will be its guardian."*

**إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ**

— Al-Hijr 15:9 (meaning)

</div>

---

## Star History

<a href="https://www.star-history.com/?repos=muhammadnaumantahir%2FImaanly&type=date&legend=bottom-right">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=muhammadnaumantahir/Imaanly&type=date&theme=dark&legend=bottom-right" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=muhammadnaumantahir/Imaanly&type=date&legend=bottom-right" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=muhammadnaumantahir/Imaanly&type=date&legend=bottom-right" />
 </picture>
</a>
