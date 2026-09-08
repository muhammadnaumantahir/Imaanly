# Athan audio sources

Imaanly currently uses five HTTPS MP3 recordings for its cross-platform Athan playback service.

Source collection: Internet Archive — **Adhan Recordings from Doha, Qatar**.

The collection/source information used for this integration is documented by the RUKN project as carrying a Public Domain Mark 1.0 notice. Before commercial distribution, re-check the upstream item metadata and rights because third-party recordings can have additional rights considerations.

Files used:

- Fajr: `Adhan_Doha_Qatar_01_Fajr_Adhan.mp3`
- Dhuhr: `Adhan_Doha_Qatar_02_Dhuhr_Adhan.mp3`
- Asr: `Adhan_Doha_Qatar_03_Asr_Adhan.mp3`
- Maghrib: `Adhan_Doha_Qatar_04_Maghrib_Adhan.mp3`
- Isha: `Adhan_Doha_Qatar_05_Isha_Adhan.mp3`

The application streams these recordings over HTTPS rather than bundling binary audio assets. This keeps the repository lightweight and allows the same `just_audio` implementation to work on Android and Chrome.

## Browser behavior

Chrome and other browsers can block autoplay. Athan playback from the UI therefore must be initiated by a user interaction. A future background/scheduled-Athan implementation must use platform-specific scheduling/background capabilities rather than assuming that a web browser can start audio while the page is inactive.
