<p align="center">
  <img src="https://img.shields.io/badge/Platform-visionOS_2.0-blue?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/macOS-14.0+-gray?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-Source_Available-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Files-101_Swift-red?style=for-the-badge" />
</p>

<h1 align="center">🧊 HOLODESK</h1>
<h3 align="center">The Spatial Workspace Platform for Apple Vision Pro</h3>
<p align="center"><i>Your room is your computer.</i></p>

---

## What is HoloDesk?

**HoloDesk** is a production-grade spatial operating system built for Apple Vision Pro on visionOS 2.0. It transforms your physical room into an infinite digital workspace — 32 floating app windows, an AI assistant, spatial audio, hand/eye tracking, and a glassmorphic design language built to Apple-level polish.

**WWDC Swift Student Challenge ready** — 100% offline, under 25 MB, 3-minute guided demo included.

---

## Architecture

HoloDesk follows **MVVM with clean modular separation**. Every layer has a single responsibility:

```
HoloDesk/
├── App/                          # Entry point
│   ├── HoloDeskApp.swift         # @main, scene types, environment injection
│   └── Info.plist                # App configuration
│
├── Core/                         # Logic & state management
│   ├── Models/                   # Data structures
│   │   ├── SpatialWindow.swift   # Window model (38 types, position, state)
│   │   ├── Workspace.swift       # Workspace model (mode, layout, windows)
│   │   └── WorkspaceStore.swift  # @Observable root state (SSOT)
│   ├── Extensions/               # SwiftUI modifiers & design tokens
│   │   ├── View+Glass.swift      # Glassmorphic material system
│   │   ├── Animation+Spatial.swift # 10 animation presets
│   │   ├── Color+Theme.swift     # Design system colors
│   │   └── Accessibility+HoloDesk.swift
│   ├── Services/                 # Singleton services
│   │   ├── WindowManager.swift   # Window CRUD, mode transitions
│   │   ├── WorkspaceManager.swift # Persistence, import/export
│   │   ├── ThemeManager.swift    # 8 workspace themes
│   │   ├── HapticManager.swift   # Haptic feedback abstraction
│   │   ├── NotificationManager.swift
│   │   ├── RoomManager.swift     # Room scanning & desk detection
│   │   ├── ScreenTimeTracker.swift
│   │   └── ProductivityTracker.swift
│   └── Persistence/              # Data persistence layer
│       ├── WorkflowTemplateManager.swift
│       └── WorkspaceTimelineManager.swift
│
├── UI/                           # SwiftUI presentation layer
│   ├── Screens/                  # Full-screen views
│   │   ├── ContentView.swift     # Main workspace (root)
│   │   ├── SplashView.swift      # Cinematic boot sequence
│   │   ├── OnboardingView.swift  # 6-page walkthrough
│   │   ├── SettingsView.swift    # App configuration
│   │   └── GuidedDemoView.swift  # 3-min WWDC judge tour
│   ├── Components/               # Reusable UI components
│   │   ├── DockView.swift        # macOS-style app dock
│   │   ├── SpatialWindowView.swift # Floating window container
│   │   ├── ModeSelectorView.swift
│   │   ├── MinimapView.swift     # Workspace bird's-eye view
│   │   ├── AppLauncherView.swift
│   │   ├── SnapLayoutPickerView.swift
│   │   └── ... (13 files)
│   └── WindowContents/           # Individual app content (32 files)
│       ├── NotesContent.swift    # Interactive multi-note editor
│       ├── TerminalContent.swift # Shell emulator (15+ commands)
│       ├── SpotifyContent.swift  # Full music player
│       ├── CalendarContent.swift # Date-computed monthly view
│       ├── ChessContent.swift    # Playable chess board
│       └── ... (27 more)
│
├── Spatial/                      # 3D / VisionOS layer
│   ├── ImmersiveSpaceView.swift  # RealityKit immersive scene
│   ├── RoomEnvironment.swift     # ARKit room reconstruction
│   ├── SkyboxEnvironment.swift   # Dynamic skybox rendering
│   ├── SpatialPortalView.swift   # Inter-space portals
│   ├── SpatialFileObject.swift   # 3D file representations
│   ├── SpatialFoundationEngine.swift
│   ├── SpatialAnchorManager.swift
│   ├── SpatialAudioManager.swift
│   ├── HandTrackingManager.swift # Gesture input abstraction
│   ├── EyeTrackingManager.swift  # Gaze-based interaction
│   ├── DeskInteractionEngine.swift
│   ├── GestureShortcutManager.swift
│   └── SpatialScreenshotManager.swift
│
├── AI/                           # Intelligence layer
│   ├── AIAssistantManager.swift  # Offline NLP + optional Gemini
│   ├── GeminiService.swift       # Google Gemini API client
│   ├── IntelligenceSystems.swift # Semantic search, context engine
│   ├── VoiceCommandManager.swift
│   ├── AIBuddyView.swift         # 3D animated AI companion
│   ├── AIAssistantView.swift     # Chat panel UI
│   └── VoiceCommandView.swift
│
├── Modules/                      # Independent feature modules
│   ├── Productivity/             # Focus timer, productivity systems
│   ├── Platform/                 # Apple ecosystem, SharePlay
│   ├── Environment/              # Ambient effects, lighting
│   ├── Creative/                 # Power tools, delight features
│   ├── Accessibility/            # AccessibilityEngine (full suite)
│   └── Widgets/                  # Desktop widget system
│
├── Assets/                       # Static resources
│   ├── Presets/                  # Mode JSON configs (Work, Study, Cinema, Gaming)
│   └── Resources/               # Icons, UI assets
│
└── RealityKitContent/            # 3D asset bundle (USDZ)
```

**Total: 101 Swift files | 20,672 lines | 220 KB zip**

### Design Patterns

| Pattern | Usage |
|---------|-------|
| **MVVM** | `WorkspaceStore` (Model) → `WindowManager` (ViewModel) → SwiftUI Views |
| **@Observable** | All managers use Swift 5.9 `@Observable` macro for reactive state |
| **Environment injection** | 22 managers injected via `.environment()` at root |
| **Single Source of Truth** | `WorkspaceStore` owns all workspace state |
| **Protocol abstraction** | Gesture/tracking layers abstracted for future hardware |
| **Offline-first** | AI runs locally by default; cloud (Gemini) is opt-in |

### Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI |
| 3D Rendering | RealityKit |
| Spatial Input | ARKit (hand tracking, eye tracking, scene reconstruction) |
| State | `@Observable` + `@Environment` (zero Combine) |
| Persistence | JSON to user documents |
| AI (Local) | Rule-based NLP with 38 intent patterns |
| AI (Cloud) | Google Gemini 2.0 Flash (optional) |
| Animation | Custom spatial presets (spring, parallax, breathe) |

---

## Features

### 32 Spatial Window Types
| Category | Apps |
|----------|------|
| **Productivity** | Mail, Calendar, Notes, To-Do, Files, Kanban, Spreadsheet, Mind Map |
| **Communication** | Messages, FaceTime, Social Feed |
| **Creative** | Code Editor, Terminal, Color Picker, 3D Model Viewer |
| **Media** | Spotify, Music, Video, Podcasts, Music Visualizer, Voice Memos |
| **Lifestyle** | Weather, Stocks, Habit Tracker, Translator, Meditation, Chess |
| **System** | Browser, Clipboard, System Monitor, Ambience Mixer, Photos |

### AI Intelligence (Offline-First)
- **38 command intents** — open/close windows, mode switching, workspace queries
- **Time-of-day awareness** — morning/afternoon/evening/night advice
- **Contextual status** — "what's open?", workspace stats, focus tips
- **Gemini cloud fallback** — toggle on for richer responses (optional)
- **3D AI Buddy** — animated companion with mood system (idle/listening/thinking/happy)

### Accessibility (WWDC-Critical)
- Voice Control (8 command phrases)
- Eye-only navigation with dwell-to-select
- One-hand mode (left/right)
- 3 colorblind modes + high contrast
- Hand tremor stabilization (weighted averaging)
- UI scaling 0.75x–2.0x
- Cognitive load reduction
- VoiceOver labels on all interactive elements

### Glassmorphic Design System
- Ultra-thin material glass with 3-stop gradient borders
- Dual shadow system for spatial depth
- Accent-colored borders with hover glow
- 10 animation presets (spawn, dismiss, breathe, parallax, pulse)
- 8 workspace themes

---

## Getting Started

### Requirements
| Requirement | Version |
|------------|---------|
| Xcode | 16.0+ |
| Swift | 5.9+ |
| visionOS SDK | 2.0 |
| macOS (host) | 14.0+ (Sonoma) |
| Hardware | Apple Vision Pro or Simulator |

### Quick Start

```bash
# 1. Clone
git clone https://github.com/notminelap/HoloDesk.git
cd HoloDesk

# 2. Open in Xcode
open Package.swift
# OR create Xcode project:
# xcodebuild -scheme HoloDesk -destination 'platform=visionOS Simulator'

# 3. Select target
# Scheme: HoloDesk → Apple Vision Pro Simulator

# 4. Build & Run
# ⌘ + R
```

### First-Time Setup (Mac)

```bash
# Install Xcode CLI tools
xcode-select --install

# Verify Swift version
swift --version  # Should be 5.9+

# Verify visionOS SDK
xcodebuild -showsdks | grep visionos
```

### Building for Device

```bash
# Archive for Apple Vision Pro
xcodebuild archive \
  -scheme HoloDesk \
  -destination 'generic/platform=visionOS' \
  -archivePath build/HoloDesk.xcarchive
```

---

## WWDC Swift Student Challenge

HoloDesk is designed to meet all WWDC submission criteria:

| Requirement | Status |
|-------------|--------|
| Swift + SwiftUI | ✅ 101 Swift files |
| Under 25 MB | ✅ 220 KB (0.88%) |
| 100% Offline | ✅ AI runs locally |
| 3-min interactive demo | ✅ GuidedDemoView |
| Accessibility | ✅ VoiceOver, eye-only, voice control |
| `.swiftpm` format | ⚠️ Convert at submission time |

---

## License

**Copyright © 2026 Notminelap Industries. All Rights Reserved.**

Source-Available License — view for education, **no copy/use/distribute** without written permission.

See [LICENSE](LICENSE) for full terms.

---

## Author

**Notminelap Industries**

Built with 🔥 for Apple Vision Pro.

<p align="center"><b>SET YOUR HEART ABLAZE</b></p>
