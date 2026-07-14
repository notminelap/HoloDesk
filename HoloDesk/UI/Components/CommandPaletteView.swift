// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Command Palette (⌘K)

/// Spotlight-style spatial command palette — the fastest way to drive HoloDesk.
/// Fuzzy-searches all 32 apps, workspace modes, and system actions from one
/// keyboard-first glass panel. Summoned with ⌘K or the header search pill.
struct CommandPaletteView: View {

    @Binding var isPresented: Bool

    /// Actions owned by ContentView, injected so the palette stays decoupled.
    let onSave: () -> Void
    let onToggleImmersive: () -> Void
    let onDemo: () -> Void
    let onSettings: () -> Void

    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Environment(SpatialAudioManager.self) private var audio
    @Environment(\.openWindow) private var openWindow

    @State private var query = ""
    @FocusState private var searchFocused: Bool

    // MARK: - Entries

    private enum SystemAction: String, CaseIterable, Identifiable {
        case save
        case immersive
        case demo
        case settings

        var id: String { rawValue }

        var title: String {
            switch self {
            case .save:      return "Save Workspace"
            case .immersive: return "Toggle Immersive Space"
            case .demo:      return "Start Guided Demo"
            case .settings:  return "Open Settings"
            }
        }

        var iconName: String {
            switch self {
            case .save:      return "square.and.arrow.down"
            case .immersive: return "cube.transparent"
            case .demo:      return "sparkles"
            case .settings:  return "gearshape.fill"
            }
        }
    }

    // MARK: - Search

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private func matches(_ title: String) -> Bool {
        if trimmedQuery.isEmpty { return true }
        return title.lowercased().contains(trimmedQuery)
    }

    /// Lower rank sorts first: prefix hits beat substring hits.
    private func rank(_ title: String) -> Int {
        if trimmedQuery.isEmpty { return 1 }
        return title.lowercased().hasPrefix(trimmedQuery) ? 0 : 1
    }

    private var filteredApps: [WindowType] {
        WindowType.allCases
            .filter { matches($0.displayName) }
            .sorted { rank($0.displayName) < rank($1.displayName) }
    }

    private var filteredModes: [WorkspaceMode] {
        WorkspaceMode.allCases.filter { matches($0.displayName + " mode") }
    }

    private var filteredActions: [SystemAction] {
        SystemAction.allCases.filter { matches($0.title) }
    }

    /// Identity of the top hit — highlighted and run on Return.
    private var firstEntryID: String? {
        if let app = filteredApps.first { return "app-\(app.rawValue)" }
        if let mode = filteredModes.first { return "mode-\(mode.rawValue)" }
        if let action = filteredActions.first { return "action-\(action.rawValue)" }
        return nil
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Dimmed backdrop — tap to dismiss
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { close() }
                .accessibilityHidden(true)

            palettePanel
        }
    }

    private var palettePanel: some View {
        VStack(spacing: 0) {
            searchBar

            Divider()
                .overlay(Color.white.opacity(0.08))

            resultsList
        }
        .frame(width: 460)
        .frame(maxHeight: 400)
        .deepGlass(cornerRadius: 22)
        .onAppear { searchFocused = true }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Command palette")
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.holoPrimary.opacity(0.9))

            TextField("Search apps, modes, actions…", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .focused($searchFocused)
                .onSubmit { runFirstEntry() }
                .accessibilityLabel("Search commands")
                .accessibilityHint("Type to filter, then press Return to run the top result.")

            Button {
                close()
            } label: {
                Text("esc")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .innerGlass(cornerRadius: 6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel("Close command palette")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 2) {
                if !filteredApps.isEmpty {
                    sectionHeader("APPS")
                    ForEach(filteredApps) { type in
                        appRow(type)
                    }
                }

                if !filteredModes.isEmpty {
                    sectionHeader("MODES")
                    ForEach(filteredModes) { mode in
                        modeRow(mode)
                    }
                }

                if !filteredActions.isEmpty {
                    sectionHeader("ACTIONS")
                    ForEach(filteredActions) { action in
                        actionRow(action)
                    }
                }

                if filteredApps.isEmpty && filteredModes.isEmpty && filteredActions.isEmpty {
                    emptyState
                }
            }
            .padding(10)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(.white.opacity(0.35))
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 3)
            .accessibilityAddTraits(.isHeader)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.stars")
                .font(.system(size: 24))
                .foregroundStyle(.white.opacity(0.25))
            Text("Nothing matches \"\(query)\"")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    // MARK: - Rows

    private func appRow(_ type: WindowType) -> some View {
        paletteRow(
            id: "app-\(type.rawValue)",
            iconName: type.iconName,
            tint: Color.windowAccent(for: type),
            title: type.displayName,
            subtitle: "Open app",
            accessibilityHint: "Opens \(type.displayName) as a spatial window."
        ) {
            launchApp(type)
        }
    }

    private func modeRow(_ mode: WorkspaceMode) -> some View {
        paletteRow(
            id: "mode-\(mode.rawValue)",
            iconName: mode.iconName,
            tint: Color.holoSecondary,
            title: "\(mode.displayName) Mode",
            subtitle: store.currentMode == mode ? "Current" : "Switch mode",
            accessibilityHint: "Transitions the workspace to \(mode.displayName) mode."
        ) {
            switchMode(mode)
        }
    }

    private func actionRow(_ action: SystemAction) -> some View {
        paletteRow(
            id: "action-\(action.rawValue)",
            iconName: action.iconName,
            tint: Color.holoTertiary,
            title: action.title,
            subtitle: "Action",
            accessibilityHint: "Runs \(action.title)."
        ) {
            run(action)
        }
    }

    private func paletteRow(
        id: String,
        iconName: String,
        tint: Color,
        title: String,
        subtitle: String,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) -> some View {
        let isTopHit = firstEntryID == id

        return Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tint.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(tint)
                }

                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))

                if isTopHit {
                    Image(systemName: "return")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.holoPrimary.opacity(0.8))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(isTopHit ? 0.06 : 0.0))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverGlow()
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }

    // MARK: - Execution

    private func runFirstEntry() {
        if let app = filteredApps.first {
            launchApp(app)
        } else if let mode = filteredModes.first {
            switchMode(mode)
        } else if let action = filteredActions.first {
            run(action)
        }
    }

    private func launchApp(_ type: WindowType) {
        audio.playSFX(.windowOpen)
        windowManager.spawnWindow(type: type, in: store)
        openWindow(id: "spatial-window", value: store.activeWindows.last?.id)
        close()
    }

    private func switchMode(_ mode: WorkspaceMode) {
        guard !windowManager.isTransitioning else { return }
        audio.playSFX(.success)
        Task {
            await windowManager.transitionToMode(mode, in: store)
        }
        close()
    }

    private func run(_ action: SystemAction) {
        audio.playSFX(.tap)
        switch action {
        case .save:      onSave()
        case .immersive: onToggleImmersive()
        case .demo:      onDemo()
        case .settings:  onSettings()
        }
        close()
    }

    private func close() {
        query = ""
        isPresented = false
    }
}
