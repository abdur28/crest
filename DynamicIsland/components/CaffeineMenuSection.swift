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

import SwiftUI

/// The "Keep Awake" controls shown in the menu-bar dropdown.
struct CaffeineMenuSection: View {
    @ObservedObject private var caffeine = CaffeineManager.shared

    var body: some View {
        Toggle("Keep Awake", isOn: Binding(
            get: { caffeine.isActive },
            set: { isOn in
                if isOn {
                    caffeine.activate(timeoutMinutes: caffeine.timeoutMinutes)
                } else {
                    caffeine.deactivate()
                }
            }
        ))

        Menu("Keep Awake For") {
            ForEach(CaffeineManager.timeoutPresets, id: \.self) { minutes in
                Button {
                    caffeine.activate(timeoutMinutes: minutes)
                } label: {
                    if caffeine.isActive && caffeine.timeoutMinutes == minutes {
                        Label(Self.label(forMinutes: minutes), systemImage: "checkmark")
                    } else {
                        Text(Self.label(forMinutes: minutes))
                    }
                }
            }
        }

        if caffeine.isActive, let endsAt = caffeine.timeoutEndsAt {
            Text("Awake until \(endsAt.formatted(date: .omitted, time: .shortened))")
        }
    }

    static func label(forMinutes minutes: Double) -> String {
        switch minutes {
        case 0:
            return "Indefinitely"
        case ..<60:
            return "\(Int(minutes)) minutes"
        case 60:
            return "1 hour"
        default:
            let hours = minutes / 60
            return hours == hours.rounded()
                ? "\(Int(hours)) hours"
                : String(format: "%.1f hours", hours)
        }
    }
}
