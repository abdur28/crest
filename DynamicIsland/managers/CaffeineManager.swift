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

import Combine
import Defaults
import Foundation
import IOKit.pwr_mgt

/// Keeps the Mac awake using an IOKit power-management assertion — the same
/// mechanism behind `/usr/bin/caffeinate`, without spawning a subprocess.
///
/// A single assertion is held while active. Its type depends on
/// ``Defaults/Keys/caffeinateKeepDisplayAwake``: when enabled it also keeps the
/// display on, otherwise only the system is prevented from idle-sleeping.
@MainActor
final class CaffeineManager: ObservableObject {
    static let shared = CaffeineManager()

    /// Whether keep-awake is currently engaged.
    @Published private(set) var isActive = false
    /// When a timeout is running, the moment keep-awake will automatically turn off.
    @Published private(set) var timeoutEndsAt: Date?

    /// Timeout presets (in minutes) offered in the UI. `0` means indefinite.
    static let timeoutPresets: [Double] = [0, 15, 30, 60, 120, 300]

    /// Human-readable label for a timeout preset.
    static func timeoutLabel(forMinutes minutes: Double) -> String {
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

    private var assertionID = IOPMAssertionID(0)
    private var timeoutTask: Task<Void, Never>?

    private init() {
        // Restore the persisted state on launch so keep-awake survives relaunches.
        if Defaults[.caffeinateEnabled] {
            activate(timeoutMinutes: Defaults[.caffeinateTimeoutMinutes])
        }
    }

    // MARK: - Public API

    /// The currently selected timeout in minutes (0 == indefinite).
    var timeoutMinutes: Double {
        Defaults[.caffeinateTimeoutMinutes]
    }

    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate(timeoutMinutes: Defaults[.caffeinateTimeoutMinutes])
        }
    }

    /// Engages keep-awake, optionally auto-disabling after `timeoutMinutes`.
    /// Passing `0` keeps the Mac awake indefinitely.
    func activate(timeoutMinutes: Double) {
        Defaults[.caffeinateTimeoutMinutes] = max(0, timeoutMinutes)

        guard acquireAssertion() else {
            deactivate()
            return
        }

        isActive = true
        Defaults[.caffeinateEnabled] = true
        scheduleTimeout(minutes: Defaults[.caffeinateTimeoutMinutes])
    }

    /// Releases the assertion and cancels any pending timeout.
    func deactivate() {
        cancelTimeout()
        releaseAssertion()
        isActive = false
        Defaults[.caffeinateEnabled] = false
    }

    /// Updates the display-sleep behaviour. Re-acquires the assertion if active
    /// so the change takes effect immediately.
    func setKeepDisplayAwake(_ keepAwake: Bool) {
        guard Defaults[.caffeinateKeepDisplayAwake] != keepAwake else { return }
        Defaults[.caffeinateKeepDisplayAwake] = keepAwake
        guard isActive else { return }
        _ = acquireAssertion()
    }

    // MARK: - IOKit Assertion

    @discardableResult
    private func acquireAssertion() -> Bool {
        // Drop any existing assertion first so the type can change cleanly.
        releaseAssertion()

        let assertionType = Defaults[.caffeinateKeepDisplayAwake]
            ? kIOPMAssertionTypePreventUserIdleDisplaySleep
            : kIOPMAssertionTypePreventUserIdleSystemSleep

        var newID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            assertionType as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Atoll keep-awake" as CFString,
            &newID
        )

        guard result == kIOReturnSuccess else { return false }
        assertionID = newID
        return true
    }

    private func releaseAssertion() {
        guard assertionID != IOPMAssertionID(0) else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = IOPMAssertionID(0)
    }

    // MARK: - Timeout

    private func scheduleTimeout(minutes: Double) {
        cancelTimeout()
        guard minutes > 0 else { return }

        let endsAt = Date().addingTimeInterval(minutes * 60)
        timeoutEndsAt = endsAt
        timeoutTask = Task { [weak self] in
            let nanos = UInt64(minutes * 60 * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanos)
            guard !Task.isCancelled else { return }
            self?.deactivate()
        }
    }

    private func cancelTimeout() {
        timeoutTask?.cancel()
        timeoutTask = nil
        timeoutEndsAt = nil
    }
}
