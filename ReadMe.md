<p align="center">
  <img src=".github/assets/crest-logo.png" alt="Crest logo" width="120">
</p>
<h1 align="center">Crest — DynamicIsland for macOS</h1>
<p align="center"><i>A private build for friends, maintained by <b>Bytesphere</b>.</i></p>

<p align="center">
  <a href="https://github.com/abdur28/crest/stargazers">
    <img src="https://img.shields.io/github/stars/abdur28/crest?style=social" alt="GitHub stars"/>
  </a>
  <a href="https://github.com/abdur28/crest-updates/releases">
    <img src="https://img.shields.io/badge/Download-Crest%20for%20macOS-0A84FF?style=for-the-badge&logo=apple" alt="Download Crest for macOS"/>
  </a>
</p>

Crest turns the MacBook notch into a focused command surface for media, system insight, and quick utilities. It stays out of the way until needed, then expands with responsive, native SwiftUI animations.

<p align="center">
  <img src="https://i.postimg.cc/t49mW5yN/Screenshot-2026-03-02-at-6-00-22-PM.png" alt="Crest lock screen" width="920">
</p>

## Highlights
- Media controls for Apple Music, Spotify, Cider, and more with inline previews.
- Live Activities for media playback, Focus, screen recording, privacy indicators, downloads, and battery/charging.
- Lock screen widgets for media, timers, charging, Bluetooth devices, and weather.
- Lightweight system insight for CPU, GPU, memory, network, and disk usage.
- Multi-output audio mixer with per-app volume, mute, and a 10-band EQ.
- Productivity tools including timers, clipboard history, color picker, and calendar previews.
- Customization for layouts, animations, hover behavior, and shortcut remapping.

## Other Features
- Gesture controls for opening/closing the notch and media navigation.
- Parallax hover interactions with smooth transitions.
- Lock screen appearance and positioning controls for panels and widgets.

<p align="center">
  <img src="https://i.postimg.cc/HkLGn6yH/846F86A4_A2F9_4CD6_BC84_1D720D377728_1_201_a.jpg" alt="Crest preview" width="920">
</p>

## Requirements
- macOS 14.0 or later (optimised for macOS 15+).
- MacBook with a notch (14/16‑inch MBP across Apple silicon generations).
- Xcode 15+ to build from source.
- Permissions as needed: Accessibility, Camera, Calendar, Screen Recording, Music.

## Installation
Crest is distributed privately as a signed, notarized build.
1) Grab the latest `Crest-*.zip` from [crest-updates releases](https://github.com/abdur28/crest-updates).
2) Unzip and drag **Crest** into Applications.
3) Launch Crest and grant the requested permissions. Updates arrive automatically via Sparkle.

## Quick Start
- Hover near the notch to expand; click to enter controls.
- Use tabs for Media, Stats, Timers, Clipboard, and more.
- Adjust layout, appearance, and shortcuts from Settings.
- Add files to Shelf from Terminal: `open -a Crest /path/to/file`.

## Settings
- Choose appearance, animation style, and per‑feature toggles.
- Remap global shortcuts and adjust hover behaviour.
- Enable lock screen widgets and select data sources.

## Gesture Controls
- Two-finger swipe down to open the notch when hover-to-open is disabled; swipe up to close.
- Enable horizontal media gestures in **Settings → General → Gesture control** to turn the music pane into a trackpad for previous/next or ±10 second seeks.
- Pick the gesture skip behaviour (track vs ±10s) independently from the skip button configuration so swipes can scrub while buttons change tracks—or vice versa.
- Horizontal swipes trigger the same haptics and button animations you see in the notch, keeping visual feedback consistent with tap interactions.

## Troubleshooting (Basics)
- After granting Accessibility or Screen Recording, quit and relaunch the app.
- If metrics are empty, enable categories in Settings → Stats.
- Media not responding: verify player is active and Music permission is granted.

## License
Crest is released under the **GPL v3** License, the same as Atoll. Refer to [LICENSE](LICENSE) for the full terms. All original Atoll copyright notices are retained, and modifications are marked in each source file's header.

## 🙏 Appreciation — built on Atoll
**Crest is a fork of [Atoll](https://github.com/Ebullioscopic/Atoll) by Ebullioscopic**, and exists entirely because of their work. Every feature above was built by the Atoll authors and contributors — Crest simply rebrands and tailors it for a small circle of friends. Heartfelt thanks to the whole Atoll team. 💙 Crest is an unaffiliated redistribution; please support and ⭐ the original at **https://github.com/Ebullioscopic/Atoll**.

Atoll, in turn, builds on the work of several open-source projects:

- [**Atoll**](https://github.com/Ebullioscopic/Atoll) — the upstream project Crest is based on.
- [**Boring.Notch**](https://github.com/TheBoredTeam/boring.notch) — foundational media player, AirDrop surface, file dock, and calendar features; core notch interaction models.
- [**Alcove**](https://tryalcove.com) — inspiration for Minimalistic Mode and lock screen widget concepts.
- [**Stats**](https://github.com/exelban/stats) — CPU temperature (SMC), IOReport frequency sampling, and per-core utilisation readers.
- [**Open Meteo**](https://open-meteo.com) — weather APIs for lock screen widgets.
- [**SkyLightWindow**](https://github.com/Lakr233/SkyLightWindow) — window rendering for lock screen widgets.
- [**rtaudio**](https://github.com/ZephyrCodesStuff/rtaudio) — live music visualizer (C++).
- [**SwiftTerm**](https://github.com/migueldeicaza/SwiftTerm) — terminal tab.
- [**DynamicNotch**](https://github.com/jackson-storm/DynamicNotch) — battery HUDs.
- Wick — iOS-like Timer design for the lock screen widget.
- [**OpenUsage**](https://github.com/robinebers/openusage) — LLM usage tracking.
- [**OpenRouter**](https://openrouter.ai) — automated model pricing API.

## Atoll contributors
Crest inherits the work of everyone who built Atoll:

<a href="https://github.com/Ebullioscopic/Atoll/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Ebullioscopic/Atoll" />
</a>
