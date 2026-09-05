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

import AtollExtensionKit
import Defaults
import SwiftUI

/// The expanded notch header.
///
/// Everything is a single row of icons driven by one ordered list
/// (`notchHeaderItemOrder`), divided by a `spacer` that is the physical notch:
/// items before it render to the left of the notch, items after to the right.
/// There is no separate "tab bar" — view-switchers (Home, Music, Stats, …) and
/// action buttons (Camera, Settings, Pin, …) live in the same reorderable list.
struct DynamicIslandHeader: View {
    @EnvironmentObject var vm: DynamicIslandViewModel
    @EnvironmentObject var webcamManager: WebcamManager
    @ObservedObject var batteryModel = BatteryStatusViewModel.shared
    @ObservedObject var coordinator = DynamicIslandViewCoordinator.shared
    @ObservedObject var clipboardManager = ClipboardManager.shared
    @ObservedObject var shelfState = ShelfStateViewModel.shared
    @ObservedObject var timerManager = TimerManager.shared
    @ObservedObject var doNotDisturbManager = DoNotDisturbManager.shared
    @ObservedObject var caffeineManager = CaffeineManager.shared
    @ObservedObject private var extensionNotchExperienceManager = ExtensionNotchExperienceManager.shared

    @State private var showClipboardPopover = false
    @State private var showColorPickerPopover = false
    @State private var showTimerPopover = false

    @Default(.enableTimerFeature) var enableTimerFeature
    @Default(.timerDisplayMode) var timerDisplayMode
    @Default(.showClipboardIcon) var showClipboardIcon
    @Default(.showColorPickerIcon) var showColorPickerIcon
    @Default(.enableColorPickerFeature) var enableColorPickerFeature
    @Default(.clipboardDisplayMode) var clipboardDisplayMode
    @Default(.enableClipboardManager) var enableClipboardManager
    @Default(.showBatteryIndicator) var showBatteryIndicator
    @Default(.showBatteryPercentInside) var showBatteryPercentInside
    @Default(.showMinimalisticBatteryIndicator) var showMinimalisticBatteryIndicator
    @Default(.enableMinimalisticUI) var enableMinimalisticUI
    @Default(.showCaffeineInNotch) var showCaffeineInNotch
    @Default(.showPinInNotch) var showPinInNotch
    @Default(.showMusicInNotch) var showMusicInNotch
    @Default(.showMultiAudioInNotch) var showMultiAudioInNotch
    @Default(.settingsIconInNotch) var settingsIconInNotch
    @Default(.dynamicShelf) var dynamicShelf
    @Default(.enableStatsFeature) var enableStatsFeature
    @Default(.enableLLMUsageFeature) var enableLLMUsageFeature
    @Default(.enableNotes) var enableNotes
    @Default(.enableTerminalFeature) var enableTerminalFeature
    @Default(.showMirror) var showMirror
    @Default(.showStandardMediaControls) var showStandardMediaControls
    @Default(.showCalendar) var showCalendar
    @Default(.accentColor) var accentColor
    @Default(.enableThirdPartyExtensions) private var enableThirdPartyExtensions
    @Default(.enableExtensionNotchExperiences) private var enableExtensionNotchExperiences
    @Default(.enableExtensionNotchTabs) private var enableExtensionNotchTabs
    @Default(.notchHeaderItemOrder) var notchHeaderItemOrder
    @Default(.notchPinned) var notchPinned

    /// Stable token so any header instance sets/clears the same pin suppression.
    private static let pinToken = UUID()

    /// Point size per symbol, so the row reads as one size. See the original
    /// note: equal point size is equal cap height, not equal optical size, so
    /// each glyph is tuned to land on ~16pt of ink height.
    private static let headerGlyphSizes: [String: CGFloat] = [
        "web.camera": 14.5,
        "list.clipboard": 13,
        "doc.on.clipboard": 13,
        "eyedropper": 14.3,
        "timer": 14.4,
        "gearshape": 14.2,
        "cup.and.saucer.fill": 13.5,
        "cup.and.saucer": 13.5,
        "music.note": 14,
        "hifispeaker.2.fill": 13.2,
        "house.fill": 13.5,
        "tray.fill": 13.5,
        "chart.xyaxis.line": 13.5,
        "chart.bar.doc.horizontal": 13,
        "note.text": 13.5,
        "apple.terminal": 13.5,
        "pin": 13,
        "pin.fill": 13
    ]

    private func headerGlyph(_ name: String, color: Color = .white) -> some View {
        Image(systemName: name)
            .foregroundColor(color)
            .font(.system(size: Self.headerGlyphSizes[name] ?? 14.4, weight: .medium))
            .frame(width: 20, height: 20)
    }

    var body: some View {
        HStack(spacing: 0) {
            // LEFT of the notch: items before the spacer, plus extension tabs.
            HStack(spacing: 8) {
                if vm.notchState == .open {
                    ForEach(leadingItems) { item in
                        itemView(item)
                    }
                    if !enableMinimalisticUI {
                        extensionChips
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(vm.notchState == .closed ? 0 : 1)
            .blur(radius: vm.notchState == .closed ? 20 : 0)
            .animation(.smooth.delay(0.1), value: vm.notchState)
            .zIndex(2)
            .padding(8)

            if vm.notchState == .open {
                let spacerWidth = min(vm.closedNotchSize.width, 300)
                Rectangle()
                    .fill(enableMinimalisticUI ? .clear : (NSScreen.screens
                        .first(where: { $0.localizedName == coordinator.selectedScreen })?.safeAreaInsets.top ?? 0 > 0 ? .black : .clear))
                    .frame(width: spacerWidth)
                    .mask {
                        NotchShape()
                    }
            }

            // RIGHT of the notch: items after the spacer, plus status indicators.
            HStack(spacing: 8) {
                if vm.notchState == .open {
                    ForEach(trailingItems) { item in
                        itemView(item)
                    }

                    if !enableMinimalisticUI {
                        if Defaults[.enableScreenRecordingDetection] && Defaults[.showRecordingIndicator] && !shouldSuppressStatusIndicators {
                            RecordingIndicator()
                                .frame(width: 30, height: 30)
                        }

                        if Defaults[.enableDoNotDisturbDetection]
                            && Defaults[.showDoNotDisturbIndicator]
                            && doNotDisturbManager.isDoNotDisturbActive
                            && !shouldSuppressStatusIndicators {
                            FocusIndicator()
                                .frame(width: 30, height: 30)
                                .transition(.opacity)
                        }
                    }
                }
            }
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(vm.notchState == .closed ? 0 : 1)
            .blur(radius: vm.notchState == .closed ? 20 : 0)
            .animation(.smooth.delay(0.1), value: vm.notchState)
            .zIndex(2)
        }
        .foregroundColor(.gray)
        .environmentObject(vm)
        .onAppear {
            vm.setAutoCloseSuppression(notchPinned, token: Self.pinToken)
            validateSelection()
        }
        .onChange(of: notchPinned) { _, isPinned in
            vm.setAutoCloseSuppression(isPinned, token: Self.pinToken)
        }
        .onChange(of: coordinator.shouldToggleClipboardPopover) { _ in
            if enableClipboardManager {
                switch clipboardDisplayMode {
                case .panel:
                    ClipboardPanelManager.shared.toggleClipboardPanel()
                case .popover:
                    showClipboardPopover.toggle()
                case .separateTab:
                    coordinator.currentView = (coordinator.currentView == .notes) ? .home : .notes
                case .notchTab:
                    AppDelegate.shared?.cancelPendingNotchAutoClose()
                    coordinator.currentView = (coordinator.currentView == .clipboard) ? .home : .clipboard
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleClipboardPopover"))) { _ in
            if enableClipboardManager && clipboardDisplayMode == .popover {
                showClipboardPopover.toggle()
            }
        }
        .onChange(of: enableTimerFeature) { _, newValue in
            if !newValue {
                showTimerPopover = false
                vm.isTimerPopoverActive = false
            }
        }
        .onChange(of: timerDisplayMode) { _, mode in
            if mode == .tab {
                showTimerPopover = false
                vm.isTimerPopoverActive = false
            }
        }
    }
}

// MARK: - Unified item ordering & dispatch

private extension DynamicIslandHeader {
    var shouldSuppressStatusIndicators: Bool {
        settingsIconInNotch
            && enableClipboardManager
            && showClipboardIcon
            && showColorPickerIcon
            && enableTimerFeature
    }

    /// The full ordered list (with any newly-added items appended).
    var orderedItems: [NotchHeaderItem] {
        NotchHeaderItem.sanitized(notchHeaderItemOrder)
    }

    /// Items before the spacer render to the left of the notch.
    var leadingItems: [NotchHeaderItem] {
        guard let idx = orderedItems.firstIndex(of: .spacer) else { return [] }
        return Array(orderedItems[..<idx])
    }

    /// Items after the spacer render to the right. With no spacer, everything
    /// falls to the right (the original layout).
    var trailingItems: [NotchHeaderItem] {
        guard let idx = orderedItems.firstIndex(of: .spacer) else { return orderedItems }
        return Array(orderedItems[(idx + 1)...])
    }

    var accentTint: Color { accentColor }

    /// Renders one item: nothing for the spacer, the battery pill for battery,
    /// a selectable chip for view-switchers, or an action button otherwise.
    @ViewBuilder
    func itemView(_ item: NotchHeaderItem) -> some View {
        switch item {
        case .spacer:
            EmptyView()
        case .battery:
            batteryView
        default:
            if !enableMinimalisticUI {
                if item.isViewSwitcher {
                    viewSwitcherChip(item)
                } else {
                    actionButton(item)
                }
            }
        }
    }

    // MARK: View-switchers (formerly the tab bar)

    @ViewBuilder
    func viewSwitcherChip(_ item: NotchHeaderItem) -> some View {
        if isItemVisible(item), let view = item.view {
            let selected = coordinator.currentView == view
            let icon = chipIcon(for: item)
            Button {
                AppDelegate.shared?.cancelPendingNotchAutoClose()
                coordinator.currentView = view
            } label: {
                Capsule()
                    .fill(selected ? accentTint.opacity(0.25) : Color.black)
                    .frame(width: 30, height: 30)
                    .overlay {
                        headerGlyph(icon, color: selected ? accentTint : .white)
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .help(item.displayName)
        }
    }

    /// Notes shows a clipboard glyph when it is standing in for the clipboard
    /// separate-tab; otherwise the item's own glyph.
    func chipIcon(for item: NotchHeaderItem) -> String {
        if item == .notes, !enableNotes {
            return "doc.on.clipboard"
        }
        return item.systemImage
    }

    @ViewBuilder
    var extensionChips: some View {
        if enableThirdPartyExtensions && enableExtensionNotchExperiences && enableExtensionNotchTabs {
            ForEach(extensionNotchExperienceManager.activeExperiences.filter { $0.descriptor.tab != nil }, id: \.descriptor.id) { payload in
                if let tab = payload.descriptor.tab {
                    let selected = coordinator.currentView == .extensionExperience
                        && coordinator.selectedExtensionExperienceID == payload.descriptor.id
                    let accent = payload.descriptor.accentColor.swiftUIColor
                    let icon = tab.iconSymbolName ?? "puzzlepiece.extension"
                    Button {
                        AppDelegate.shared?.cancelPendingNotchAutoClose()
                        coordinator.selectedExtensionExperienceID = payload.descriptor.id
                        coordinator.currentView = .extensionExperience
                    } label: {
                        Capsule()
                            .fill(selected ? accent.opacity(0.25) : Color.black)
                            .frame(width: 30, height: 30)
                            .overlay {
                                Image(systemName: icon)
                                    .foregroundColor(selected ? accent : .white)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 20, height: 20)
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(tab.title)
                }
            }
        }
    }

    /// Whether a view-switcher tab is currently home-visible.
    var homeTabVisible: Bool {
        if enableMinimalisticUI { return true }
        return showStandardMediaControls || showCalendar || showMirror
    }

    // MARK: Action buttons

    @ViewBuilder
    func actionButton(_ item: NotchHeaderItem) -> some View {
        switch item {
        case .camera:
            if isItemVisible(item) { cameraButton }
        case .clipboard:
            if isItemVisible(item) { clipboardButton }
        case .colorPicker:
            if isItemVisible(item) { colorPickerButton }
        case .timer:
            if enableTimerFeature && timerDisplayMode == .popover { timerButton }
        case .settings:
            if isItemVisible(item) { settingsButton }
        case .caffeine:
            if isItemVisible(item) { caffeineButton }
        case .pin:
            if isItemVisible(item) { pinButton }
        default:
            EmptyView()
        }
    }

    // MARK: Visibility & selection validity

    func isItemVisible(_ item: NotchHeaderItem) -> Bool {
        switch item {
        case .home: return homeTabVisible
        case .music: return showMusicInNotch
        case .multiAudio: return showMultiAudioInNotch
        case .shelf: return dynamicShelf
        case .stats: return enableStatsFeature
        case .usage: return enableLLMUsageFeature
        case .notes: return enableNotes || (enableClipboardManager && clipboardDisplayMode == .separateTab)
        case .terminal: return enableTerminalFeature
        case .timer: return enableTimerFeature
        case .camera: return showMirror
        case .clipboard: return enableClipboardManager && showClipboardIcon && clipboardDisplayMode != .separateTab
        case .colorPicker: return enableColorPickerFeature && showColorPickerIcon
        case .settings: return settingsIconInNotch
        case .caffeine: return showCaffeineInNotch
        case .pin: return showPinInNotch
        case .battery: return showBatteryIndicator
        case .spacer: return false
        }
    }

    /// If the current view is a view-switcher whose item is hidden, fall back to
    /// Home. Leaves popover/panel views (clipboard, extensions) alone.
    func validateSelection() {
        let switchableViews: Set<NotchViews> = [.home, .music, .multiAudio, .shelf, .stats, .llmUsage, .notes, .terminal, .timer]
        guard switchableViews.contains(coordinator.currentView) else { return }

        let visibleViews = Set(orderedItems.compactMap { item -> NotchViews? in
            guard let view = item.view, isItemVisible(item) else { return nil }
            return view
        })

        if !visibleViews.contains(coordinator.currentView) {
            coordinator.currentView = .home
        }
    }

    // MARK: Button views

    var cameraButton: some View {
        Button(action: { vm.toggleCameraPreview() }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay { headerGlyph("web.camera") }
        }
        .buttonStyle(PlainButtonStyle())
    }

    var clipboardButton: some View {
        Button(action: {
            switch clipboardDisplayMode {
            case .panel:
                ClipboardPanelManager.shared.toggleClipboardPanel()
            case .popover:
                showClipboardPopover.toggle()
            case .separateTab:
                coordinator.currentView = .notes
            case .notchTab:
                AppDelegate.shared?.cancelPendingNotchAutoClose()
                coordinator.currentView = (coordinator.currentView == .clipboard) ? .home : .clipboard
            }
        }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay { headerGlyph("list.clipboard") }
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showClipboardPopover, arrowEdge: .bottom) {
            ClipboardPopover()
        }
        .onChange(of: showClipboardPopover) { isActive in
            vm.isClipboardPopoverActive = isActive
            if !isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.shouldRecheckHover.toggle()
                }
            }
        }
        .onAppear {
            if enableClipboardManager && !clipboardManager.isMonitoring {
                clipboardManager.startMonitoring()
            }
        }
    }

    var colorPickerButton: some View {
        Button(action: {
            switch Defaults[.colorPickerDisplayMode] {
            case .panel:
                ColorPickerPanelManager.shared.toggleColorPickerPanel()
            case .popover:
                showColorPickerPopover.toggle()
            }
        }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay { headerGlyph("eyedropper") }
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showColorPickerPopover, arrowEdge: .bottom) {
            ColorPickerPopover()
        }
        .onChange(of: showColorPickerPopover) { isActive in
            vm.isColorPickerPopoverActive = isActive
            if !isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.shouldRecheckHover.toggle()
                }
            }
        }
    }

    var timerButton: some View {
        Button(action: {
            withAnimation(.smooth) { showTimerPopover.toggle() }
        }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay { headerGlyph("timer") }
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showTimerPopover, arrowEdge: .bottom) {
            TimerPopover()
        }
        .onChange(of: showTimerPopover) { isActive in
            vm.isTimerPopoverActive = isActive
            if !isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.shouldRecheckHover.toggle()
                }
            }
        }
    }

    var settingsButton: some View {
        Button(action: { SettingsWindowController.shared.showWindow() }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay { headerGlyph("gearshape") }
        }
        .buttonStyle(PlainButtonStyle())
    }

    var caffeineButton: some View {
        Button(action: { caffeineManager.toggle() }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay {
                    headerGlyph(
                        caffeineManager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer",
                        color: caffeineManager.isActive ? .yellow : .white
                    )
                }
        }
        .buttonStyle(PlainButtonStyle())
        .help(caffeineManager.isActive ? "Keep Awake: On" : "Keep Awake: Off")
    }

    var pinButton: some View {
        Button(action: { notchPinned.toggle() }) {
            Capsule().fill(.black).frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: notchPinned ? "pin.fill" : "pin")
                        .foregroundColor(notchPinned ? .yellow : .white)
                        .font(.system(size: 13, weight: .medium))
                        .rotationEffect(.degrees(notchPinned ? 0 : 45))
                        .frame(width: 20, height: 20)
                }
        }
        .buttonStyle(PlainButtonStyle())
        .help(notchPinned ? "Unpin (allow auto-close)" : "Pin notch open")
    }

    @ViewBuilder
    var batteryView: some View {
        if vm.notchState == .open && showBatteryIndicator {
            if enableMinimalisticUI {
                if !shouldUseDynamicIslandMode(for: vm.screen) && showMinimalisticBatteryIndicator {
                    MinimalisticBatteryView(
                        levelBattery: batteryModel.levelBattery,
                        isPluggedIn: batteryModel.isPluggedIn,
                        isCharging: batteryModel.isCharging,
                        isInLowPowerMode: batteryModel.isInLowPowerMode,
                        bodyWidth: 28,
                        bodyHeight: 14,
                        isForNotification: false,
                        showPercentInside: showBatteryPercentInside
                    )
                    .padding(.trailing, 4)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            } else {
                DynamicIslandBatteryView(
                    batteryWidth: 30,
                    isCharging: batteryModel.isCharging,
                    isInLowPowerMode: batteryModel.isInLowPowerMode,
                    isPluggedIn: batteryModel.isPluggedIn,
                    levelBattery: batteryModel.levelBattery,
                    maxCapacity: batteryModel.maxCapacity,
                    timeToFullCharge: batteryModel.timeToFullCharge,
                    isForNotification: false
                )
            }
        }
    }
}

#Preview {
    DynamicIslandHeader()
        .environmentObject(DynamicIslandViewModel())
        .environmentObject(WebcamManager.shared)
}
