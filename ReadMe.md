<h1 align="center">Crest — DynamicIsland for macOS</h1>

<p align="center">
  A private build shared among friends, maintained by <strong>Bytesphere</strong>.
</p>

Crest turns the MacBook notch into a focused command surface for media, system insight, and quick utilities. It stays out of the way until needed, then expands with responsive, native SwiftUI animations.

> **Crest is a fork of [Atoll](https://github.com/Ebullioscopic/Atoll) by Ebullioscopic**, released under the GPL v3. Enormous thanks to the Atoll authors and contributors — Crest exists only because of their work. This repository is a modified distribution and is **not affiliated with or endorsed by** the Atoll project. For the original, upstream app, please visit [Atoll](https://github.com/Ebullioscopic/Atoll).

## Highlights
- Media controls for Apple Music, Spotify, Cider, and more with inline previews.
- Live Activities for media playback, Focus, screen recording, privacy indicators, downloads, and battery/charging.
- Lock screen widgets for media, timers, charging, Bluetooth devices, and weather.
- Lightweight system insight for CPU, GPU, memory, network, and disk usage.
- Productivity tools including timers, clipboard history, color picker, and calendar previews.
- Multi-output audio mixer with per-app volume, mute, and 10-band EQ.
- Customization for layouts, animations, hover behavior, and shortcut remapping.

## Requirements
- macOS 14.0 or later (optimised for macOS 15+).
- MacBook with a notch.
- Xcode 15+ to build from source.
- Permissions as needed: Accessibility, Camera, Calendar, Screen Recording, Music.

## Install
Crest is distributed privately as a signed, notarized build. Open the app and grant the requested permissions on first launch. Updates are delivered automatically via Sparkle.

## Building from source
Open `DynamicIsland.xcodeproj` in Xcode and build the `DynamicIsland` scheme. Signing is configured for the Bytesphere team (Developer ID for release).

## License
Crest, like Atoll, is released under the **GPL v3**. See [LICENSE](LICENSE) for the full terms. All original Atoll copyright notices are retained; modifications are marked in each source file's header.

## Acknowledgments
Crest inherits the excellent work of [Atoll](https://github.com/Ebullioscopic/Atoll) and the projects Atoll builds upon, including:

- [**Atoll**](https://github.com/Ebullioscopic/Atoll) — the upstream project this fork is based on.
- [**Boring.Notch**](https://github.com/TheBoredTeam/boring.notch) — foundational notch interaction models and media/file-dock/calendar features.
- [**Stats**](https://github.com/exelban/stats) — system metrics (SMC/IOReport) readers.
- [**Open Meteo**](https://open-meteo.com) — weather API for lock screen widgets.
- [**SkyLightWindow**](https://github.com/Lakr233/SkyLightWindow) — window rendering for lock screen widgets.
- [**rtaudio**](https://github.com/ZephyrCodesStuff/rtaudio) — live music visualizer.
- [**SwiftTerm**](https://github.com/migueldeicaza/SwiftTerm) — terminal tab.
- [**DynamicNotch**](https://github.com/jackson-storm/DynamicNotch) — battery HUDs.

See the [Atoll README](https://github.com/Ebullioscopic/Atoll) for the complete list of acknowledgments and contributors.
