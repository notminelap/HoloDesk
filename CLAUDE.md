# CLAUDE.md — HoloDesk

Context handoff for Claude Code sessions on any machine. A long Windows-side
session (July 2026) fixed the build, added features, and set up CI; this file
carries everything that session learned. **Today's mission: Docs/MAC_DAY_RUNBOOK.md.**

## What this is

HoloDesk — a spatial workspace platform for Apple Vision Pro (visionOS 27 /
min visionOS 2). Pure SwiftUI + RealityKit, Swift 6 strict concurrency, zero
third-party dependencies, ~27.5k lines across 111 files. The user's Apple
Swift Student Challenge 2027 submission.

## ⚠️ THE ONE CRITICAL RULE

**Run the app via `HoloDesk.xcodeproj`. NEVER `open Package.swift` to run.**
The package's Xcode fallback product is a command-line executable: it builds
successfully but has no app bundle, so the simulator launches NOTHING. This
cost an entire borrowed-Mac day once. The xcodeproj is a native visionOS app
target (all 109 sources, assets, presets, App/Info.plist) and is what CI builds.
`Package.swift`'s iOSApplication branch is for Swift Playgrounds on iPad only —
app playgrounds have no `.vision` device family (CI-proven).

## Build & run

- Xcode: open `HoloDesk.xcodeproj`, scheme **HoloDesk**, destination
  **Apple Vision Pro simulator**, ⌘R.
- Headless (CI parity):
  `xcodebuild build -project HoloDesk.xcodeproj -scheme HoloDesk -destination 'generic/platform=visionOS Simulator' CODE_SIGNING_ALLOWED=NO`
- CI (`.github/workflows/build.yml`, macos-26 runner) builds every push to
  main. It is the project's only compiler when working from Windows. Repo must
  stay public or macOS CI minutes bill at 10x.

## Conventions (user-set, do not violate)

- **NO `Co-Authored-By: Claude` trailers on commits** — explicit user request.
- Zero dependencies: never add packages. All audio is synthesized (no files),
  all art is vector/procedural.
- Swift 6 strict concurrency: managers are `@MainActor @Observable final class`.
  NotificationCenter closures must extract Sendable values before hopping to
  the main actor.
- Type-checker safety: break big SwiftUI expressions into `let` bindings
  (View+Glass.swift got a timeout once); qualify ambiguous ternaries
  (`Color.white` not `.white` when mixing with opacity variants).
- House UI style: `glassBackground()/innerGlass()/deepGlass()`, `hoverGlow()`
  (which includes gaze `hoverEffect(.lift)` — don't stack a second one),
  `Color.holoPrimary/Secondary/Tertiary`, procedural SFX via
  `audio.playSFX(...)` on every interaction.

## Recently shipped, NEVER yet run by a human (verify per the runbook)

- ⌘K Command Palette (`UI/Components/CommandPaletteView.swift`) — header pill
  toggles it too; Return runs top hit; Esc closes.
- Real-room transformation: `preferredSurroundingsEffect` per mode in
  `ImmersiveSpaceView` (cinema=systemDark, study=warm, gaming=violet;
  custom reads AppStorage dials `holodesk_custom_dimming/_tint_on/_hue`
  set in Settings ▸ Custom Room Ambience). Only visible while the immersive
  space is open.
- Custom mode intentionally does NOT run a preset transition (no preset file
  exists — it would wipe all windows); it keeps the layout and just sets
  `store.currentMode = .custom`.
- `openWindow(id: "spatial-window", value:)` takes a NON-optional UUID — the
  scene is `WindowGroup(for: UUID.self)`; passing `UUID?` silently opens
  nothing (this bug was in the codebase from day one, fixed at two sites).
- Audio engine self-heals on route changes/interruptions; all synth paths
  guard `engine.isRunning` after a start attempt (play() on a stopped engine
  is an uncatchable NSException).

## Known open items

- Preflight review: 2 of 4 lenses never ran (state-logic, audio-lifecycle) —
  session limits. Worth a careful manual pass on those areas.
- RealityKit y-axis audit in the immersive space (SwiftUI y-down vs RealityKit
  y-up) — never verified visually.
- Glass shimmer uses repeatForever animations on every panel — watch thermals.
- Swift Playgrounds open-test for SSC compliance — never done (runbook Phase 4).
- Fresh screenshots per the runbook shot-list → then update README from any machine.

## End of a borrowed-Mac day (non-negotiable)

`git add` + commit + **push everything** (screenshots, notes, fixes) before the
Mac goes back. Anything unpushed is lost to the next Windows session.
