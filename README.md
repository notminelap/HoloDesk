<p align="center">
  <img src="https://img.shields.io/badge/Platform-visionOS_2.0-blue?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/License-Source_Available-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Files-97_Swift-purple?style=for-the-badge" />
</p>

<h1 align="center">🧊 HOLODESK</h1>
<h3 align="center">The Spatial Workspace Platform for Apple Vision Pro</h3>
<p align="center"><i>Your room is your computer.</i></p>

---

## What is HoloDesk?

**HoloDesk** is a AAA-quality spatial operating system built for Apple Vision Pro on visionOS 2.0. It transforms your physical room into an infinite digital workspace — where windows float in air, files sit on your desk, and your entire computing experience lives in spatial space.

Think of it as **macOS meets spatial computing** — with 35 app types, AI intelligence, Apple ecosystem integration, and a glassmorphic design language that makes everything feel premium.

---

## Features

### 35 Spatial Window Types
| Category | Apps |
|----------|------|
| **Productivity** | Mail, Calendar, Notes, To-Do, Files, Kanban, Spreadsheet, Mind Map |
| **Communication** | Messages, FaceTime, Social Feed |
| **Creative** | Code Editor, Terminal, Whiteboard, Color Picker, 3D Model Viewer |
| **Media** | Spotify, Music, Video, Podcasts, Music Visualizer, Voice Memos |
| **Lifestyle** | Weather, Stocks, Habit Tracker, Translator, Meditation, Chess |
| **System** | Browser, Clipboard, System Monitor, Ambience Mixer |

### AI Intelligence
- **Daily Briefing** — weather, meetings, tasks, and AI-suggested layouts
- **Weekly Insights** — focus hours, streaks, top apps, improvement tips
- **Context-Aware Layouts** — 6 contexts (meeting, coding, creative, etc.)
- **Time-of-Day Adaptation** — morning to deep work to evening to night modes
- **Semantic Search** — Spotlight-style search across all windows and content

### Apple Ecosystem Integration
- Mac Virtual Display with resolution switching
- Universal Clipboard spatial paste tray
- AirDrop throw gesture to nearby devices
- iCloud workspace sync
- Safari tabs, Reminders, Calendar, FaceTime integration

### Glassmorphic Design System
- Ultra-thin material glass with 3-stop gradient borders
- Dual shadow system for realistic depth
- macOS-style traffic light window controls
- Accent-colored borders that glow on hover
- 10+ animation presets (spawn, move, breathe, parallax, dismiss)
- 8 workspace themes

### Real-Time Collaboration
- Shared desk sessions with multi-user editing
- Remote pointer visualization
- Presentation mode with privacy bubbles
- Guest workspace isolation

### Accessibility
- Full voice control (8 commands)
- Eye-only navigation with dwell-to-select
- One-hand mode (left/right)
- 3 colorblind modes + high contrast
- Hand tremor stabilization
- UI scaling (0.75x to 2.0x)
- Cognitive load reduction mode
- Closed captions

### Wellness and Delight
- Break reminders with breathing exercises
- Growing desk plants (water them!)
- Achievement badges and productivity streaks
- Ambient sound mixer (10 channels)
- Focus timer with analytics

### Power User Tools
- 5 desk layouts (Single, L-Shape, Dual, U-Shape, Standing)
- 10 keyboard shortcuts with HUD
- Plugin marketplace (Notion, Figma, GitHub, Pomodoro)
- Developer API (6 REST endpoints)
- Automation scripts with custom gestures
- Workspace export/import
- Debug overlay (FPS, memory, thermal)

### Smart Home Hub
- 8 device types with spatial controls
- 5 scene presets (Morning, Focus, Movie, Night, Party)
- Real-time status monitoring

---

## Architecture

```
HoloDesk/
├── HoloDeskApp.swift                 # App entry, 3 scene types, 29 managers
├── Models/           (3 files)       # SpatialWindow, Workspace, WorkspaceStore
├── Extensions/       (4 files)       # Glass, Animation, Color, Accessibility
├── Managers/         (31 files)      # All system managers
├── Views/            (18 files)      # UI views and panels
│   ├── Spatial/      (5 files)       # Immersive, portals, skybox
│   ├── Widgets/      (1 file)        # Widget system
│   └── WindowContents/ (32 files)    # Individual window content views
└── RealityKitContent/ (2 files)      # 3D assets package
```

**Total: 97 Swift files | 109 files overall**

### Tech Stack
- **SwiftUI** with @Observable state management
- **RealityKit** for spatial rendering
- **ARKit** for desk detection, hand tracking, eye tracking
- **visionOS 2.0** scene types: WindowGroup, ImmersiveSpace, Volumetric

---

## Getting Started

### Requirements
- Xcode 16+
- visionOS 2.0 SDK
- Apple Vision Pro (or Simulator)

### Build
```bash
git clone https://github.com/notminelap/HoloDesk.git
cd HoloDesk
open HoloDesk.xcodeproj
# Select Apple Vision Pro simulator -> Build and Run
```

---

## License

**Copyright 2026 Notminelap Industries. All Rights Reserved.**

This project uses a custom **Source-Available License**. You may view the source code for educational purposes, but you **may not** copy, use, modify, or distribute it without explicit written permission from Notminelap Industries.

See [LICENSE](LICENSE) for full terms.

---

## Author

**Notminelap Industries**

Built with fire for Apple Vision Pro.

---

<p align="center">
  <b>SET YOUR HEART ABLAZE</b>
</p>
