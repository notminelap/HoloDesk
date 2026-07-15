# 🗓️ Mac Day Runbook — One Saturday, Maximum Output

> You have the MacBook for **one day**. This is the script. Don't improvise the order —
> it's sorted so that if the day gets cut short, the most important things are already done.
> The Mac already has **macOS 27.2 beta + Xcode beta** installed (newer than CI's Xcode 26.5,
> so anything CI builds, this Mac builds).

---

## ⏱️ Phase 0 — Pre-flight (10 min)

```bash
# Fresh clone — NOT inside OneDrive/iCloud folders. Cloud sync + .git = corruption.
mkdir -p ~/Developer && cd ~/Developer
git clone https://github.com/notminelap/HoloDesk.git
cd HoloDesk
open Package.swift
```

- [ ] Xcode opens the package, scheme **HoloDesk** appears
- [ ] Run destination: **Apple Vision Pro** simulator (if missing: Xcode ▸ Settings ▸ Components ▸ visionOS simulator runtime)
- [ ] **⌘R** — it should build clean (CI has verified every commit; if it doesn't build, something is environmental, not the code)

---

## 🏁 Phase 1 — Smoke test & victory lap (45 min)

Run through in order, tick as you go:

- [ ] Splash boot sequence plays; the typewriter says **"111 Swift Source Files"** and **"27,500+ Lines of Code"**
- [ ] Launch chime plays (procedural audio engine alive)
- [ ] Onboarding appears (first launch), completes into the main deck
- [ ] **⌘K opens the Command Palette** (needs the Mac keyboard focused on the simulator window; the header 🔍 pill is the click fallback)
- [ ] Type `che` → top hit shows ↩ badge → **Return** → Chess spawns as a spatial window
- [ ] Palette: type `cinema` → Return → full mode transition runs
- [ ] Esc closes the palette; empty-query Return launches top app (expected)
- [ ] Open the immersive space (dock **Space** button)
- [ ] **Mode → Cinema with immersive open: the room passthrough dims theater-dark** (SurroundingsEffect — never been seen live)
- [ ] Study mode → warm lamplight tint; Gaming → violet tint; Work → clean passthrough
- [ ] Settings ▸ **Custom Room Ambience** → Custom mode → drag dimming/hue sliders → room updates **live**
- [ ] Look at dock buttons in the headset-eye sense: gaze hover should lift them (`hoverEffect(.lift)` — simulator: hover with pointer)

## 🔎 Phase 2 — The judge-eye sweep (60 min)

- [ ] Open all 32 apps from the palette one by one; note any layout glitch (screenshot anything broken)
- [ ] Immersive space: check entity heights/positions (RealityKit is y-up; SwiftUI y-down — the audit we never could do from Windows). Buddy at eye level? Files on the desk, not in the floor?
- [ ] Audio: dock taps click, mode switch arpeggios, ambient drone in immersive space; **connect/disconnect AirPods once** — sound must survive (engine-recovery code)
- [ ] Fans/heat after 15 min: if the Mac runs hot, note it (glass shimmer animations are the suspect — we tune later, don't fix on Mac day)
- [ ] VoiceOver spot check (⌘F5): dock buttons and palette rows announce sensibly

## 📸 Phase 3 — Screenshot shot-list (30 min)

Simulator ▸ File ▸ Save Screen, or: `xcrun simctl io booted screenshot <name>.png`
Save all into `Docs/Images/`, commit from the Mac. Shot list (these update the README):

| Filename | Scene |
|---|---|
| `visionos_command_palette.png` | ⌘K open, query `ch`, results showing |
| `visionos_cinema_dimming.png` | Immersive + Cinema mode, room dimmed, theater spawned |
| `visionos_custom_ambience.png` | Settings ambience section + hue-washed room behind |
| `visionos_main_deck.png` | Fresh main control window (replaces stale shots) |
| `visionos_immersive_overview.png` | Immersive space wide view: buddy, files, constellation |

## 🧪 Phase 4 — SSC compliance check (20 min) — DO NOT SKIP

- [ ] Open the project in **Swift Playgrounds** on the Mac (SSC judges run app playgrounds; the `AppleProductTypes` branch of Package.swift exists exactly for this). Confirm it opens and builds there, not just in Xcode.
- [ ] Note the built bundle size (README claims ~220 KB; verify it's still in that ballpark)

## 🎥 Phase 5 — Demo video (30 min, if time remains)

QuickTime ▸ New Screen Recording over the simulator: boot → ⌘K → `chess` → immersive → Cinema dim → custom hue slider. 60–90 seconds, no narration needed. Save as `Docs/holodesk_demo.mov` (or upload separately if >50 MB — don't commit huge files).

## 📤 Phase 6 — End-of-day protocol (10 min, NON-NEGOTIABLE)

```bash
git add Docs/Images/*.png
git commit -m "Add real simulator screenshots from Mac session"
git push origin main
```

- [ ] Push **everything** before handing the Mac back — screenshots, any quick fixes, notes
- [ ] If anything was broken and you couldn't fix it: paste the error/output into a file `Docs/mac_day_notes.md`, commit, push — it can be fixed from Windows with CI verifying

---

## 🚑 Troubleshooting

| Symptom | Fix |
|---|---|
| Build fails in Xcode but CI is green | Xcode ▸ Product ▸ Clean Build Folder (⇧⌘K); check the simulator runtime is installed |
| ⌘K doesn't open palette | Click the simulator window first (keyboard focus), or use the header 🔍 pill |
| No sound | Mac volume; simulator ▸ I/O ▸ Audio; verify chime on relaunch |
| Room doesn't dim in Cinema | The SurroundingsEffect only applies while the **immersive space is open** |
| Simulator sluggish | Close other apps; simulator ▸ Graphics Quality Override → Faster |
