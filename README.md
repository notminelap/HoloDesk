<p align="center">
  <img src="https://img.shields.io/badge/Swift_Student_Challenge-2027-orange?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-visionOS_2.0-blue?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftUI-Spatial-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/badge/100%25-Offline-brightgreen?style=for-the-badge" />
</p>

<h1 align="center">🧊 HOLODESK</h1>
<h3 align="center">Spatial Workspace Platform for Apple Vision Pro</h3>
<p align="center"><i>Swift Student Challenge 2027 — Your room is your computer.</i></p>
<p align="center"><b>By Notminelap Industries</b></p>

---

## 🏆 Swift Student Challenge Submission

HoloDesk is my submission for the **Apple Swift Student Challenge 2027**. It reimagines the desktop metaphor for spatial computing — transforming your physical room into an infinite digital workspace with 32 floating app windows, an on-device AI assistant, spatial audio, hand/eye tracking, and a glassmorphic design language built entirely in Swift.

### Why HoloDesk?

I believe the future of computing isn't flat screens — it's spatial. HoloDesk demonstrates that a single student developer can build a production-grade spatial operating system using only Swift, SwiftUI, and RealityKit. Every feature runs 100% on-device with zero external dependencies.

### Challenge Requirements

| Requirement | Status |
|-------------|--------|
| Swift + SwiftUI | ✅ 101 Swift files, 20,672 lines |
| Swift Playground App (.swiftpm) | ✅ Package.swift configured |
| Under 25 MB | ✅ 220 KB (0.88%) |
| 100% Offline | ✅ AI runs entirely on-device |
| 3-min interactive demo | ✅ GuidedDemoView built-in |
| Accessibility | ✅ VoiceOver, eye-only, voice control |
| No external dependencies | ✅ Zero third-party libraries |

---

## 📱 How to Run

### Swift Playgrounds (iPad/Mac)
```
1. Download HoloDesk.swiftpm
2. Open in Swift Playgrounds 4.5+
3. Tap "Run My App"
```

### Xcode (Full Development)
```bash
git clone https://github.com/notminelap/HoloDesk.git
cd HoloDesk
open Package.swift
# Select: HoloDesk → Apple Vision Pro Simulator
# ⌘ + R to build and run
```

### Requirements
| Tool | Version |
|------|---------|
| Xcode | 16.0+ |
| Swift | 5.9+ |
| visionOS SDK | 2.0 |
| macOS | 14.0+ (Sonoma) |
| Swift Playgrounds | 4.5+ (iPad/Mac) |

---

## 🏗️ Architecture

HoloDesk follows **MVVM with clean modular separation** across 7 modules:

```
HoloDesk/
├── App/           (2)   → Entry point, scene configuration
├── Core/          (17)  → Models, Extensions, Services, Persistence
│   ├── Models/          → SpatialWindow, Workspace, WorkspaceStore
│   ├── Extensions/      → Glass materials, animations, theme colors
│   ├── Services/        → WindowManager, HapticManager, RoomManager
│   └── Persistence/     → JSON workspace save/load
├── UI/            (50)  → SwiftUI presentation layer
│   ├── Screens/         → ContentView, Splash, Onboarding, Settings
│   ├── Components/      → Dock, SpatialWindow, ModeSelector
│   └── WindowContents/  → 32 individual app views
├── Spatial/       (13)  → RealityKit + ARKit spatial layer
├── AI/            (7)   → Offline NLP + optional Gemini cloud
├── Modules/       (11)  → Productivity, Platform, Creative, Accessibility
└── Assets/        (7)   → Presets (JSON), Resources
```

**Total: 101 Swift files | 20,672 lines | Zero external dependencies**

### Design Patterns

| Pattern | Usage |
|---------|-------|
| **MVVM** | WorkspaceStore (Model) → WindowManager (ViewModel) → SwiftUI Views |
| **@Observable** | All 32 managers use Swift 5.9 Observation framework |
| **Environment injection** | 22 managers injected at root via `.environment()` |
| **Single Source of Truth** | WorkspaceStore owns all workspace state |
| **Offline-first AI** | 38 NLP intents run on-device; Gemini is opt-in |

---

## ✨ Features

### 32 Spatial Window Types
| Category | Apps |
|----------|------|
| **Productivity** | Mail, Calendar, Notes, To-Do, Files, Kanban, Spreadsheet, Mind Map |
| **Communication** | Messages, FaceTime, Social Feed |
| **Creative** | Code Editor, Terminal, Color Picker, 3D Model Viewer, Whiteboard |
| **Media** | Spotify, Music, Video, Podcasts, Music Visualizer, Voice Memos |
| **Lifestyle** | Weather, Stocks, Habits, Translator, Meditation, Chess |
| **System** | Browser, Clipboard, System Monitor, Ambience Mixer, Photos |

### On-Device AI Assistant
- **38 command intents** — fully offline, zero latency
- **Time-aware intelligence** — morning/afternoon/evening advice
- **Workspace context** — knows what's open, suggests actions
- **3D AI Buddy** — animated companion with mood states
- **Optional Gemini** — toggle cloud AI for richer responses

### Accessibility (WWDC-Critical)
- Complete VoiceOver labels on all interactive elements
- Eye-only navigation with dwell-to-select
- One-hand mode (left/right)
- 3 colorblind modes + high contrast
- Hand tremor stabilization
- UI scaling 0.75x–2.0x
- Voice Control (8 command phrases)

### Spatial Computing
- RealityKit immersive spaces with room scanning
- Hand tracking gesture abstraction
- Eye tracking gaze interaction
- Spatial audio positioning
- Dynamic skybox environments
- Inter-space portals

### Glassmorphic Design System
- Ultra-thin material glass with gradient borders
- 10 custom animation presets (spawn, dismiss, breathe, parallax)
- 8 workspace themes
- Dual shadow system for spatial depth

---

## 🎬 3-Minute Demo Walkthrough

The built-in `GuidedDemoView` provides a timed, interactive tour:

1. **0:00–0:30** — Splash screen + Onboarding highlights
2. **0:30–1:00** — Workspace modes (Work → Study → Cinema)
3. **1:00–1:45** — Window interactions (Notes, Terminal, Chess)
4. **1:45–2:15** — AI Assistant conversation demo
5. **2:15–2:45** — Accessibility features showcase
6. **2:45–3:00** — Immersive space + finale

---

## 🔧 Technical Highlights

### What I'm Most Proud Of

1. **Zero-dependency architecture** — Everything is built from scratch in pure Swift. No CocoaPods, no SPM dependencies, no external frameworks.

2. **Offline-first AI** — The 38-intent NLP engine provides instant responses without network access. Pattern matching, time-awareness, and workspace context create surprisingly intelligent interactions.

3. **Glassmorphic design system** — Custom SwiftUI view modifiers create Apple-grade glass materials with gradient borders, dual shadows, and hover effects.

4. **Proper timer management** — Every animation timer is stored, tracked, and invalidated on view disappear. Zero memory leaks.

5. **MVVM at scale** — 22 environment-injected managers with clean separation. AI doesn't import UI. Spatial doesn't import AI.

---

## 📄 License

**Copyright © 2026 Notminelap Industries. All Rights Reserved.**

HoloDesk Source-Available License — You may view the source code for educational purposes. You may NOT copy, modify, distribute, or use this code without explicit written permission from Notminelap Industries.

See [LICENSE](LICENSE) for full terms.

---

<p align="center">
  <b>Built with 🔥 for the Swift Student Challenge 2027</b><br/>
  <i>Notminelap Industries</i>
</p>
