/*
 * Atoll (DynamicIsland)
 * Copyright (C) 2024-2026 Atoll Contributors
 * Modified 2026 by Bytesphere. Distributed as "Crest".
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import Defaults
import Foundation

/// A single, unified ordering of everything that can appear in the expanded
/// notch header — both the left-hand view-switching tabs and the right-hand
/// action buttons — divided by a `spacer` that represents the physical notch.
///
/// This is the one source of truth the user reorders in Settings. The header
/// derives the tab order and the button order from it (see `tab` / `button`),
/// so the existing tab bar and button rendering are reused unchanged.
enum NotchHeaderItem: String, CaseIterable, Defaults.Serializable, Identifiable {
    // View-switching tabs (left of the notch)
    case home
    case multiAudio
    case shelf
    case stats
    case usage
    case notes
    case terminal
    // Mode-dependent: a tab in tab mode, a button in popover mode
    case timer
    // Action buttons (right of the notch)
    case music
    case camera
    case clipboard
    case colorPicker
    case settings
    case caffeine
    case battery
    case pin
    // The physical notch divider
    case spacer

    var id: String { rawValue }

    /// Tabs first (left of notch), spacer, then buttons (right of notch).
    static let defaultOrder: [NotchHeaderItem] = [
        .home, .music, .multiAudio, .shelf, .stats, .usage, .notes, .terminal,
        .spacer,
        .camera, .clipboard, .colorPicker, .timer, .settings, .caffeine, .battery, .pin
    ]

    /// The stored order with any items missing (e.g. added in a newer version)
    /// appended so nothing disappears.
    static func sanitized(_ stored: [NotchHeaderItem]) -> [NotchHeaderItem] {
        // Drop any duplicates (keeping the first occurrence), then append any
        // items missing entirely so every item appears exactly once.
        var seen = Set<NotchHeaderItem>()
        var order = stored.filter { seen.insert($0).inserted }
        order.append(contentsOf: allCases.filter { !seen.contains($0) })
        return order
    }

    /// The notch view this item switches to, if it currently behaves as a
    /// view-switcher. Timer is only a view-switcher in tab mode.
    var view: NotchViews? {
        switch self {
        case .home: return .home
        case .music: return .music
        case .multiAudio: return .multiAudio
        case .shelf: return .shelf
        case .stats: return .stats
        case .usage: return .llmUsage
        case .notes: return .notes
        case .terminal: return .terminal
        case .timer: return Defaults[.timerDisplayMode] == .tab ? .timer : nil
        default: return nil
        }
    }

    var isViewSwitcher: Bool { view != nil }

    /// The tab identity this item drives, if it currently behaves as a tab.
    var tab: NotchTab? {
        switch self {
        case .home: return .home
        case .multiAudio: return .multiAudio
        case .shelf: return .shelf
        case .stats: return .stats
        case .usage: return .usage
        case .notes: return .notes
        case .terminal: return .terminal
        case .music: return .music
        case .timer: return Defaults[.timerDisplayMode] == .tab ? .timer : nil
        default: return nil
        }
    }

    /// The button identity this item drives, if it currently behaves as a button.
    var button: NotchHeaderButton? {
        switch self {
        case .spacer: return .spacer
        case .camera: return .camera
        case .clipboard: return .clipboard
        case .colorPicker: return .colorPicker
        case .settings: return .settings
        case .caffeine: return .caffeine
        case .battery: return .battery
        case .pin: return .pin
        case .timer: return Defaults[.timerDisplayMode] == .popover ? .timer : nil
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .home: return String(localized: "Home")
        case .multiAudio: return String(localized: "Multi-Audio")
        case .shelf: return String(localized: "Shelf")
        case .stats: return String(localized: "Stats")
        case .usage: return String(localized: "Usage")
        case .notes: return String(localized: "Notes")
        case .terminal: return String(localized: "Terminal")
        case .timer: return String(localized: "Timer")
        case .music: return String(localized: "Music")
        case .camera: return String(localized: "Camera")
        case .clipboard: return String(localized: "Clipboard")
        case .colorPicker: return String(localized: "Color Picker")
        case .settings: return String(localized: "Settings")
        case .caffeine: return String(localized: "Keep Awake")
        case .battery: return String(localized: "Battery")
        case .pin: return String(localized: "Pin")
        case .spacer: return String(localized: "Notch (divider)")
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .multiAudio: return "hifispeaker.2.fill"
        case .shelf: return "tray.fill"
        case .stats: return "chart.xyaxis.line"
        case .usage: return "chart.bar.doc.horizontal"
        case .notes: return "note.text"
        case .terminal: return "apple.terminal"
        case .timer: return "timer"
        case .music: return "music.note"
        case .camera: return "web.camera"
        case .clipboard: return "list.clipboard"
        case .colorPicker: return "eyedropper"
        case .settings: return "gearshape"
        case .caffeine: return "cup.and.saucer"
        case .battery: return "battery.100"
        case .pin: return "pin"
        case .spacer: return "rectangle.split.2x1"
        }
    }

    /// Whether this item sits to the left of the notch (before the spacer). Only
    /// meaningful for display grouping in Settings.
    var isDivider: Bool { self == .spacer }

    /// The existing feature/appearance toggle that governs this item's
    /// visibility, if a simple bool exists. `home` and `spacer` have none.
    var visibilityKey: Defaults.Key<Bool>? {
        switch self {
        case .shelf: return .dynamicShelf
        case .stats: return .enableStatsFeature
        case .usage: return .enableLLMUsageFeature
        case .notes: return .enableNotes
        case .terminal: return .enableTerminalFeature
        case .timer: return .enableTimerFeature
        case .music: return .showMusicInNotch
        case .multiAudio: return .showMultiAudioInNotch
        case .camera: return .showMirror
        case .clipboard: return .showClipboardIcon
        case .colorPicker: return .showColorPickerIcon
        case .settings: return .settingsIconInNotch
        case .caffeine: return .showCaffeineInNotch
        case .battery: return .showBatteryIndicator
        case .pin: return .showPinInNotch
        case .home, .spacer: return nil
        }
    }
}
