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

/// A tab in the notch's left-hand tab bar whose position is user-configurable
/// via drag-to-reorder in Settings.
///
/// Like ``NotchHeaderButton``, visibility is not stored here: each tab reuses
/// its existing feature toggle (see ``visibilityKey``), so enabling/disabling a
/// tab is the same as enabling/disabling its feature. Dynamic extension tabs are
/// appended separately and are not part of this ordering.
enum NotchTab: String, CaseIterable, Defaults.Serializable, Identifiable {
    case home
    case music
    case multiAudio
    case shelf
    case timer
    case stats
    case usage
    case notes
    case terminal

    var id: String { rawValue }

    static let defaultOrder: [NotchTab] = [.home, .music, .multiAudio, .shelf, .timer, .stats, .usage, .notes, .terminal]

    var displayName: String {
        switch self {
        case .home: return String(localized: "Home")
        case .music: return String(localized: "Music")
        case .multiAudio: return String(localized: "Multi-Audio")
        case .shelf: return String(localized: "Shelf")
        case .timer: return String(localized: "Timer")
        case .stats: return String(localized: "Stats")
        case .usage: return String(localized: "Usage")
        case .notes: return String(localized: "Notes")
        case .terminal: return String(localized: "Terminal")
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .music: return "music.note"
        case .multiAudio: return "hifispeaker.2.fill"
        case .shelf: return "tray.fill"
        case .timer: return "timer"
        case .stats: return "chart.xyaxis.line"
        case .usage: return "chart.bar.doc.horizontal"
        case .notes: return "note.text"
        case .terminal: return "apple.terminal"
        }
    }

    /// The existing feature toggle that governs whether this tab appears.
    /// `home` is governed by the media/calendar/mirror controls and `timer` by
    /// its display-mode setting, so neither exposes a single bool here.
    var visibilityKey: Defaults.Key<Bool>? {
        switch self {
        case .shelf: return .dynamicShelf
        case .stats: return .enableStatsFeature
        case .usage: return .enableLLMUsageFeature
        case .notes: return .enableNotes
        case .terminal: return .enableTerminalFeature
        case .music: return .showMusicInNotch
        case .multiAudio: return .showMultiAudioInNotch
        case .home, .timer: return nil
        }
    }
}
