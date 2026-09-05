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

/// A button (or spacer) in the expanded notch header, whose position is
/// user-configurable via drag-to-reorder in Settings.
///
/// Visibility is *not* stored here — each button reuses its existing feature
/// toggle (see ``visibilityKey``) so there is a single source of truth. This
/// type only governs ordering and the `spacer` divider.
enum NotchHeaderButton: String, CaseIterable, Defaults.Serializable, Identifiable {
    case spacer
    case music
    case camera
    case clipboard
    case colorPicker
    case timer
    case settings
    case caffeine
    case battery
    case pin

    var id: String { rawValue }

    /// The default left-to-right order. A leading spacer keeps the buttons
    /// clustered at the trailing edge — matching the original fixed layout.
    static let defaultOrder: [NotchHeaderButton] = [
        .spacer, .music, .camera, .clipboard, .colorPicker, .timer, .settings, .caffeine, .battery, .pin
    ]

    var displayName: String {
        switch self {
        case .spacer: return String(localized: "Spacer")
        case .music: return String(localized: "Music")
        case .camera: return String(localized: "Camera")
        case .clipboard: return String(localized: "Clipboard")
        case .colorPicker: return String(localized: "Color Picker")
        case .timer: return String(localized: "Timer")
        case .settings: return String(localized: "Settings")
        case .caffeine: return String(localized: "Keep Awake")
        case .battery: return String(localized: "Battery")
        case .pin: return String(localized: "Pin")
        }
    }

    var systemImage: String {
        switch self {
        case .spacer: return "arrow.left.and.right"
        case .music: return "music.note"
        case .camera: return "web.camera"
        case .clipboard: return "list.clipboard"
        case .colorPicker: return "eyedropper"
        case .timer: return "timer"
        case .settings: return "gearshape"
        case .caffeine: return "cup.and.saucer"
        case .battery: return "battery.100"
        case .pin: return "pin"
        }
    }

    /// The existing Defaults toggle that controls this button's visibility, if
    /// one exists. `spacer` has none; `timer` is governed by its display-mode
    /// setting rather than a simple bool.
    var visibilityKey: Defaults.Key<Bool>? {
        switch self {
        case .music: return .showMusicInNotch
        case .camera: return .showMirror
        case .clipboard: return .showClipboardIcon
        case .colorPicker: return .showColorPickerIcon
        case .settings: return .settingsIconInNotch
        case .caffeine: return .showCaffeineInNotch
        case .battery: return .showBatteryIndicator
        case .pin: return .showPinInNotch
        case .timer, .spacer: return nil
        }
    }
}
