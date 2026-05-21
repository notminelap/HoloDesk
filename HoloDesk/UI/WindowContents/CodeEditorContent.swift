// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Code Editor Content

/// Syntax-highlighted code editor with line numbers and language selector.
struct CodeEditorContent: View {
    
    @State private var code: String = """
    import SwiftUI
    
    struct HoloDesk: App {
        @State var store = WorkspaceStore()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(store)
            }
            
            ImmersiveSpace(id: "immersive") {
                ImmersiveSpaceView()
            }
        }
    }
    """
    @State private var language = "Swift"
    @State private var cursorLine = 1
    
    private let languages = ["Swift", "Python", "JavaScript", "TypeScript", "Rust", "Go"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Menu {
                    ForEach(languages, id: \.self) { lang in
                        Button(lang) { language = lang }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 10))
                        Text(language)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .innerGlass(cornerRadius: 6)
                }
                
                Spacer()
                
                Text("Line \(cursorLine)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                
                Button { } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
                
                Button { } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.2))
            
            // Editor
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(1...lineCount, id: \.self) { num in
                            Text("\(num)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(num == cursorLine ? .cyan : .white.opacity(0.2))
                                .frame(height: 18)
                        }
                    }
                    .padding(.horizontal, 8)
                    .background(.white.opacity(0.03))
                    
                    // Syntax highlighted lines
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(codeLines.enumerated()), id: \.offset) { i, line in
                            syntaxLine(line, lineNumber: i + 1)
                                .frame(height: 18)
                                .onTapGesture { cursorLine = i + 1 }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer()
                }
            }
            .background(Color(white: 0.05))
        }
    }
    
    private var codeLines: [String] { code.components(separatedBy: "\n") }
    private var lineCount: Int { max(codeLines.count, 1) }
    
    // Simple syntax highlighting
    private func syntaxLine(_ line: String, lineNumber: Int) -> some View {
        let highlighted = highlightSyntax(line)
        return HStack(spacing: 0) {
            // Current line highlight
            if lineNumber == cursorLine {
                Text(highlighted)
                    .font(.system(size: 11, design: .monospaced))
                    .background(.cyan.opacity(0.05))
            } else {
                Text(highlighted)
                    .font(.system(size: 11, design: .monospaced))
            }
            Spacer()
        }
    }
    
    private func highlightSyntax(_ line: String) -> AttributedString {
        var result = AttributedString(line)
        result.foregroundColor = .white.opacity(0.75)
        
        let keywords = ["import", "struct", "var", "let", "func", "class", "enum", "case", "return", "some", "private", "public"]
        let types = ["SwiftUI", "App", "Scene", "WindowGroup", "ImmersiveSpace", "View", "State", "String", "Int", "Bool"]
        
        for keyword in keywords {
            if let range = result.range(of: keyword) {
                result[range].foregroundColor = .systemPink
                result[range].font = .system(size: 11, weight: .medium, design: .monospaced)
            }
        }
        for type in types {
            if let range = result.range(of: type) {
                result[range].foregroundColor = .cyan
            }
        }
        // Strings
        if let openQuote = result.range(of: "\"") {
            result[openQuote.lowerBound...].foregroundColor = .orange
        }
        // Comments
        if let comment = result.range(of: "//") {
            result[comment.lowerBound...].foregroundColor = Color(white: 0.4)
        }
        
        return result
    }
}
