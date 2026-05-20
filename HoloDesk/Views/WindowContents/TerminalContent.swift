// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Terminal Window Content (v2.0)

/// Full-featured spatial terminal with rich command set, neofetch, and tab support.
struct TerminalContent: View {
    
    @State private var commandInput = ""
    @State private var history: [TerminalLine] = [
        TerminalLine(type: .system, text: "HoloDesk Terminal v2.0 — Spatial Shell"),
        TerminalLine(type: .system, text: "Type 'help' for available commands. Type 'neofetch' for system info."),
    ]
    @State private var commandHistory: [String] = []
    @State private var historyIndex: Int = -1
    
    struct TerminalLine: Identifiable {
        let id = UUID()
        var type: LineType
        var text: String
        
        enum LineType {
            case system, prompt, output, error, success
            
            var color: Color {
                switch self {
                case .system:  return .cyan
                case .prompt:  return .green
                case .output:  return Color(white: 0.75)
                case .error:   return .red
                case .success: return .green
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack(spacing: 6) {
                Circle().fill(.red.opacity(0.8)).frame(width: 8, height: 8)
                Circle().fill(.yellow.opacity(0.8)).frame(width: 8, height: 8)
                Circle().fill(.green.opacity(0.8)).frame(width: 8, height: 8)
                
                Spacer()
                
                Text("holodesk@spatial:~")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
                
                Text("\(history.count) lines")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.4))
            
            // Output
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(history) { line in
                            HStack(spacing: 0) {
                                if line.type == .prompt {
                                    Text("❯ ")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.green)
                                }
                                Text(line.text)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(line.type.color)
                                    .textSelection(.enabled)
                                Spacer()
                            }
                            .id(line.id)
                        }
                    }
                    .padding(10)
                }
                .background(Color(white: 0.02))
                .onChange(of: history.count) { _, _ in
                    if let last = history.last {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input
            HStack(spacing: 6) {
                Text("❯")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
                
                TextField("", text: $commandInput)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.white)
                    .onSubmit { executeCommand() }
                
                // Clear button
                if !commandInput.isEmpty {
                    Button { commandInput = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.black.opacity(0.3))
        }
    }
    
    private func executeCommand() {
        guard !commandInput.isEmpty else { return }
        let cmd = commandInput.trimmingCharacters(in: .whitespaces)
        history.append(TerminalLine(type: .prompt, text: cmd))
        commandHistory.append(cmd)
        commandInput = ""
        
        switch cmd.lowercased() {
        case "help":
            addOutput("""
            Available commands:
              ls          List directory contents
              pwd         Print working directory
              whoami      Current user
              date        Current date and time
              clear       Clear terminal
              echo <msg>  Print message
              neofetch    System information
              uptime      System uptime
              uname       OS information
              cat <file>  Read file contents
              swift       Swift REPL info
              git status  Repository status
              history     Command history
              exit        Close terminal
            """)
        case "clear":
            history.removeAll()
        case "whoami":
            addOutput("holodesk-user")
        case "date":
            addOutput(Date().formatted(date: .complete, time: .standard))
        case "ls":
            addOutput("HoloDesk.xcodeproj  Sources/  Views/  Models/  Managers/  Extensions/  README.md  LICENSE  Package.swift")
        case "ls -la":
            addOutput("""
            drwxr-xr-x  12 holodesk  staff   384 May 20 13:30 .
            drwxr-xr-x   3 holodesk  staff    96 May 12 10:00 ..
            -rw-r--r--   1 holodesk  staff  8865 May 20 13:22 HoloDeskApp.swift
            drwxr-xr-x   8 holodesk  staff   256 May 20 13:30 Views/
            drwxr-xr-x   6 holodesk  staff   192 May 20 13:25 Managers/
            drwxr-xr-x   4 holodesk  staff   128 May 20 13:17 Extensions/
            drwxr-xr-x   3 holodesk  staff    96 May 20 12:46 Models/
            -rw-r--r--   1 holodesk  staff  1024 May 20 12:46 README.md
            -rw-r--r--   1 holodesk  staff   512 May 12 10:00 LICENSE
            """)
        case "pwd":
            addOutput("/Users/holodesk/Developer/HoloDesk")
        case "neofetch":
            addNeofetch()
        case "uptime":
            addOutput("13:30  up 4 days, 7:22, 1 user, load averages: 1.42 1.38 1.45")
        case "uname", "uname -a":
            addOutput("visionOS 2.0 HoloDesk Kernel Version 24.0.0: Darwin arm64 Apple Vision Pro")
        case "swift", "swift --version":
            addOutput("Swift version 6.0 (swift-6.0-RELEASE)\nTarget: arm64-apple-visionos2.0")
        case "git status":
            addSuccess("""
            On branch main
            Your branch is up to date with 'origin/main'.
            
            nothing to commit, working tree clean
            """)
        case "git log", "git log --oneline":
            addOutput("""
            ef58cca 🏆 WWDC Swift Student Challenge Readiness
            969de67 🐛🎨 WWDC Quality Audit — 8 Critical Fixes
            1452abf 🎨 Ultra-Realistic Visual Polish Pass
            0e4151d 🤖 Gemini AI Integration + 3D AI Buddy
            25b64c1 🧊 HoloDesk v2.0.0 — The Spatial Workspace Platform
            """)
        case "history":
            let hist = commandHistory.enumerated().map { "  \($0.offset + 1)  \($0.element)" }.joined(separator: "\n")
            addOutput(hist.isEmpty ? "No history" : hist)
        case let s where s.hasPrefix("echo "):
            addOutput(String(s.dropFirst(5)))
        case let s where s.hasPrefix("cat "):
            let file = String(s.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            addOutput("cat: \(file): displaying preview...\n// \(file)\n// HoloDesk Spatial Workspace\n// Copyright (c) 2026 Notminelap Industries")
        case "exit":
            addOutput("Goodbye! 👋")
        default:
            addError("zsh: command not found: \(cmd)")
        }
        HapticManager.shared.lightTap()
    }
    
    private func addOutput(_ text: String) {
        history.append(TerminalLine(type: .output, text: text))
    }
    
    private func addError(_ text: String) {
        history.append(TerminalLine(type: .error, text: text))
    }
    
    private func addSuccess(_ text: String) {
        history.append(TerminalLine(type: .success, text: text))
    }
    
    private func addNeofetch() {
        let art = """
                   ████████
              ████          ████       holodesk-user@HoloDesk
            ██  ██████████████  ██     ─────────────────────
          ██  ██              ██  ██   OS:      visionOS 2.0
          ██  ██   HOLODESK   ██  ██   Host:    Apple Vision Pro
          ██  ██              ██  ██   Kernel:  Darwin 24.0.0
            ██  ██████████████  ██     Shell:   HoloDeskShell 2.0
              ████          ████       DE:      SwiftUI + RealityKit
                   ████████            WM:      Spatial Window Manager
                                       Apps:    32 built-in
                                       AI:      Gemini 2.0 Flash (Offline)
                                       Files:   101 Swift sources
                                       Lines:   19,973
                                       Dev:     Notminelap Industries
        """
        history.append(TerminalLine(type: .system, text: art))
    }
}
