// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spatial Window View

/// An individual spatial window — the glassmorphic container with title bar and content.
/// This is what gets opened as a separate visionOS window in space.
struct SpatialWindowView: View {
    
    let window: SpatialWindow
    
    @Environment(WindowManager.self) private var windowManager
    @Environment(WorkspaceStore.self) private var store
    @Environment(SpatialAudioManager.self) private var audio
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var isAppeared = false
    @State private var isHovering = false
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            titleBar
            
            Divider()
                .overlay(Color.windowAccent(for: window.type).opacity(0.3))
            
            windowContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
        .frame(width: window.width, height: window.height)
        .glassBackground(cornerRadius: 24, shadowRadius: isHovering ? 20 : 12)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            // Accent border glow on hover
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    Color.windowAccent(for: window.type).opacity(isHovering ? 0.25 : 0),
                    lineWidth: 1
                )
                .animation(.easeInOut(duration: 0.25), value: isHovering)
        )
        .scaleEffect(isAppeared ? 1 : 0.3)
        .opacity(isAppeared ? 1 : 0)
        .onHover { isHovering = $0 }
        .onAppear {
            withAnimation(.spatialSpawn) {
                isAppeared = true
            }
            audio.playSFX(.windowOpen, at: window.position)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(window.type.displayName) window")
    }
    
    // MARK: - Title Bar
    
    private var titleBar: some View {
        HStack(spacing: 8) {
            // Traffic lights (macOS-style)
            HStack(spacing: 5) {
                trafficLight(.red) {
                    withAnimation(.spatialDismiss) { isAppeared = false }
                    audio.playSFX(.windowClose, at: window.position)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        windowManager.dismissWindow(id: window.id, in: store)
                    }
                }
                trafficLight(.yellow) {
                    // Minimize — hide window
                    HapticManager.shared.lightTap()
                }
                trafficLight(.green) {
                    // Maximize — expand to full
                    HapticManager.shared.lightTap()
                }
            }
            .opacity(isHovering ? 1 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            
            Spacer()
            
            // App icon + title (centered)
            HStack(spacing: 6) {
                Image(systemName: window.type.iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.windowAccent(for: window.type))
                
                Text(window.type.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Right-side spacer to balance traffic lights
            HStack(spacing: 5) {
                Color.clear.frame(width: 10, height: 10)
                Color.clear.frame(width: 10, height: 10)
                Color.clear.frame(width: 10, height: 10)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial.opacity(0.3))
    }
    
    // MARK: - Traffic Light Button
    
    private func trafficLight(_ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color.opacity(isHovering ? 0.9 : 0.4))
                .frame(width: 10, height: 10)
                .overlay(
                    Circle().strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Content Router
    
    @ViewBuilder
    private var windowContent: some View {
        switch window.type {
        case .messages:      MessagesContent()
        case .calendar:      CalendarContent()
        case .notes:         NotesContent()
        case .music:         MusicContent()
        case .photos:        PhotosContent()
        case .files:         FilesContent()
        case .weather:       WeatherContent()
        case .todo:          TodoContent()
        case .video:         VideoContent()
        case .browser:       BrowserContent()
        case .whiteboard:    WhiteboardAppContent()
        case .spotify:       SpotifyContent()
        case .podcast:       PodcastContent()
        case .kanban:        KanbanContent()
        case .mindMap:       MindMapContent()
        case .codeEditor:    CodeEditorContent()
        case .terminal:      TerminalContent()
        case .meditation:    MeditationContent()
        case .visualizer:    MusicVisualizerContent()
        case .modelViewer:   ModelViewerContent()
        case .ambienceMixer: AmbienceMixerContent()
        case .facetime:      FaceTimeContent()
        case .stocks:        StocksContent()
        case .habits:        HabitTrackerContent()
        case .translator:    TranslatorContent()
        case .clipboard:     ClipboardContent()
        case .chess:         ChessContent()
        case .mail:          MailContent()
        case .voiceMemos:    VoiceMemosContent()
        case .spreadsheet:   SpreadsheetContent()
        case .systemMonitor: SystemMonitorContent()
        case .socialFeed:    SocialFeedContent()
        case .colorPicker:   ColorPickerProContent()
        }
    }
}
