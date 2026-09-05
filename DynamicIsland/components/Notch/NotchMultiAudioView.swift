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

import AppKit
import SwiftUI

struct NotchMultiAudioView: View {
    @EnvironmentObject var vm: DynamicIslandViewModel
    @ObservedObject private var manager = MultiAudioManager.shared
    @State private var activeBundleIDs: [String] = []
    @State private var perAppRevision = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if !manager.hasCapturePermission {
                permissionNeededView
            } else if activeBundleIDs.isEmpty {
                emptyView
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(activeBundleIDs, id: \.self) { bundleID in
                            NotchMultiAudioAppRow(bundleID: bundleID, revision: perAppRevision)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .blur(radius: vm.notchState == .closed ? 30 : 0)
        .onAppear(perform: refreshActiveApps)
        .onReceive(NotificationCenter.default.publisher(for: .multiAudioActiveBundlesDidChange)) { _ in
            refreshActiveApps()
        }
        .onReceive(NotificationCenter.default.publisher(for: .perAppAudioSettingsDidChange)) { _ in
            perAppRevision += 1
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "hifispeaker.2.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            Text("Multi-Audio")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            if !activeBundleIDs.isEmpty {
                Text("\(activeBundleIDs.count) active")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var permissionNeededView: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Screen Recording needed")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                Text("Grant access in Settings to mix app audio.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Grant") { manager.requestCapturePermission() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(12)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.secondary)
            Text("No active app audio")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
            Text("Start playback in an app to control it here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func refreshActiveApps() {
        activeBundleIDs = manager.activeAudioBundleIDs().sorted { lhs, rhs in
            notchMultiAudioAppName(for: lhs).localizedCaseInsensitiveCompare(notchMultiAudioAppName(for: rhs)) == .orderedAscending
        }
    }
}

private struct NotchMultiAudioAppRow: View {
    let bundleID: String
    let revision: Int
    @State private var isExpanded = false

    private let frequencies = ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: PerAppAudioController.shared.mute(for: bundleID) ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundStyle(PerAppAudioController.shared.mute(for: bundleID) ? .red : .secondary)
                        .frame(width: 18)
                    Slider(value: volumeBinding, in: 0...1, step: 0.01)
                    Text("\(Int(PerAppAudioController.shared.volume(for: bundleID) * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 42, alignment: .trailing)
                }

                HStack {
                    Toggle("Mute", isOn: muteBinding)
                        .toggleStyle(.switch)
                    Spacer()
                    Button("Flat") {
                        PerAppAudioController.shared.setEQGains(Array(repeating: 0.0, count: 10), for: bundleID)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
                .font(.caption)

                ForEach(Array(frequencies.enumerated()), id: \.offset) { index, label in
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)
                        Slider(value: eqBinding(at: index), in: -12...12, step: 0.5)
                        Text("\(eqGain(at: index), specifier: "%+.1f")")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 42, alignment: .trailing)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            HStack(spacing: 10) {
                notchMultiAudioAppIcon(for: bundleID)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                VStack(alignment: .leading, spacing: 1) {
                    Text(notchMultiAudioAppName(for: bundleID))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(bundleID)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if PerAppAudioController.shared.mute(for: bundleID) {
                    Image(systemName: "speaker.slash.fill")
                        .foregroundStyle(.red)
                } else {
                    Text("\(Int(PerAppAudioController.shared.volume(for: bundleID) * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(isExpanded ? 0.12 : 0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var volumeBinding: Binding<Double> {
        Binding(
            get: { PerAppAudioController.shared.volume(for: bundleID) },
            set: { PerAppAudioController.shared.setVolume($0, for: bundleID) }
        )
    }

    private var muteBinding: Binding<Bool> {
        Binding(
            get: { PerAppAudioController.shared.mute(for: bundleID) },
            set: { PerAppAudioController.shared.setMute($0, for: bundleID) }
        )
    }

    private func eqBinding(at index: Int) -> Binding<Double> {
        Binding(
            get: { eqGain(at: index) },
            set: { newValue in
                var gains = PerAppAudioController.shared.eqGains(for: bundleID)
                while gains.count < frequencies.count { gains.append(0.0) }
                gains[index] = newValue
                PerAppAudioController.shared.setEQGains(gains, for: bundleID)
            }
        )
    }

    private func eqGain(at index: Int) -> Double {
        let gains = PerAppAudioController.shared.eqGains(for: bundleID)
        guard gains.indices.contains(index) else { return 0.0 }
        return gains[index]
    }
}

private func notchMultiAudioAppName(for bundleID: String) -> String {
    if let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleID }) {
        return app.localizedName ?? bundleID
    }
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
        return FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
    }
    return bundleID
}

private func notchMultiAudioAppIcon(for bundleID: String) -> Image {
    let icon: NSImage
    if let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleID }), let url = app.bundleURL {
        icon = NSWorkspace.shared.icon(forFile: url.path)
    } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
        icon = NSWorkspace.shared.icon(forFile: url.path)
    } else {
        icon = NSWorkspace.shared.icon(for: .application)
    }
    return Image(nsImage: icon)
}
