// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Terminal Window Content

/// Command line terminal with input, history, and output.
struct TerminalContent: View {
    
    @State private var commandInput = ""
    @State private var history: [TerminalLine] = [
        TerminalLine(type: .system, text: "HoloDesk Terminal v1.0"),
        TerminalLine(type: .system, text: "Type 'help' for available commands."),
        TerminalLine(type: .prompt, text: "$ ls"),
        TerminalLine(type: .output, text: "Documents/  Projects/  Downloads/  Desktop/"),
        TerminalLine(type: .prompt, text: "$ pwd"),
        TerminalLine(type: .output, text: "/Users/holodesk/workspace"),
        TerminalLine(type: .prompt, text: "$ swift --version"),
        TerminalLine(type: .output, text: "Swift version 5.9 (swift-5.9-RELEASE)"),
    ]
    
    struct TerminalLine: Identifiable {
        let id = UUID()
        var type: LineType
        var text: String
        
        enum LineType {
            case system, prompt, output, error
            
            var color: Color {
                switch self {
                case .system: return .cyan
                case .prompt: return .green
                case .output: return Color(white: 0.75)
                case .error:  return .red
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack(spacing: 6) {
                Circle().fill(.red.opacity(0.7)).frame(width: 8, height: 8)
                Circle().fill(.yellow.opacity(0.7)).frame(width: 8, height: 8)
                Circle().fill(.green.opacity(0.7)).frame(width: 8, height: 8)
                
                Spacer()
                
                Text("Terminal — zsh")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.3))
            
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
                .background(Color(white: 0.03))
                .onChange(of: history.count) { _, _ in
                    if let last = history.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
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
                    .onSubmit {
                        executeCommand()
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.black.opacity(0.2))
        }
    }
    
    private func executeCommand() {
        guard !commandInput.isEmpty else { return }
        let cmd = commandInput
        history.append(TerminalLine(type: .prompt, text: cmd))
        commandInput = ""
        
        // Simulated command responses
        switch cmd.lowercased().trimmingCharacters(in: .whitespaces) {
        case "help":
            history.append(TerminalLine(type: .output, text: "Available: ls, pwd, whoami, date, clear, echo, swift, help"))
        case "clear":
            history.removeAll()
        case "whoami":
            history.append(TerminalLine(type: .output, text: "holodesk-user"))
        case "date":
            history.append(TerminalLine(type: .output, text: Date().formatted()))
        case "ls":
            history.append(TerminalLine(type: .output, text: "HoloDesk.xcodeproj  Sources/  Tests/  Package.swift  README.md"))
        case "pwd":
            history.append(TerminalLine(type: .output, text: "/Users/holodesk/spatial-workspace"))
        case let s where s.hasPrefix("echo "):
            history.append(TerminalLine(type: .output, text: String(s.dropFirst(5))))
        default:
            history.append(TerminalLine(type: .error, text: "zsh: command not found: \(cmd)"))
        }
        HapticManager.shared.lightTap()
    }
}
