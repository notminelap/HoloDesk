# Contributing to HoloDesk

Thank you for your interest in HoloDesk! This project is a personal submission for the **Apple Swift Student Challenge 2027** by [Radhesh Ranvijay](https://github.com/notminelap).

## 📋 Contribution Policy

HoloDesk is published under a **Source-Available License**. While the code is publicly viewable for educational purposes, contributions are accepted under specific guidelines:

### ✅ What We Accept

- **Bug Reports** — Found a crash, layout issue, or logic error? Open an issue with:
  - Device/simulator info
  - Steps to reproduce
  - Expected vs. actual behavior
  - Screenshots if applicable

- **Documentation Improvements** — Typo fixes, clarifications, or additional code comments

- **Accessibility Enhancements** — Improvements to VoiceOver labels, color contrast, or navigation

- **Performance Optimizations** — Measurable FPS/memory improvements with before/after metrics

### ❌ What We Don't Accept

- New feature additions (this is a curated SSC submission)
- Third-party dependency introductions
- UI redesigns or branding changes
- Code that requires network connectivity

## 🛠️ Development Setup

1. **macOS Tahoe 26.4+** with **Xcode 16+**
2. Clone the repo and open `Package.swift` in Xcode
3. Target **Apple Vision Pro Simulator**
4. Build with **⌘ + R**

## 📐 Code Style

- Pure SwiftUI — no UIKit bridging
- `@Observable` for state management (no `ObservableObject`)
- `.environment()` for dependency injection
- Every file includes copyright header
- Comments explain *why*, not *what*

## 🔍 Before Submitting

- [ ] Code compiles without warnings on visionOS 2.0 target
- [ ] No third-party imports added
- [ ] Existing tests still pass
- [ ] Copyright headers preserved
- [ ] Changes described in PR description

## 📄 License

By submitting a pull request, you agree that your contributions will be licensed under the same [HoloDesk Source-Available License](LICENSE) as the rest of the project.

---

<p align="center">
  <sub>Built with ❤️ by Radhesh Ranvijay</sub>
</p>
