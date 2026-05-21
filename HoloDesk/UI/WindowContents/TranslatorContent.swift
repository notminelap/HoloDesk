// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Translator Content

/// Real-time language translator with language picker and history.
struct TranslatorContent: View {
    
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var sourceLang = "English"
    @State private var targetLang = "Spanish"
    @State private var history: [(source: String, target: String, from: String, to: String)] = [
        ("Hello, how are you?", "Hola, ¿cómo estás?", "English", "Spanish"),
        ("Good morning", "Bonjour", "English", "French"),
    ]
    
    private let languages = ["English", "Spanish", "French", "German", "Japanese", "Korean", "Chinese", "Hindi", "Arabic", "Portuguese", "Italian", "Russian"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.blue)
                Text("Translator")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Language selector
            HStack(spacing: 8) {
                Menu {
                    ForEach(languages, id: \.self) { lang in
                        Button(lang) { sourceLang = lang }
                    }
                } label: {
                    Text(sourceLang)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .innerGlass(cornerRadius: 8)
                }
                
                Button {
                    let temp = sourceLang
                    sourceLang = targetLang
                    targetLang = temp
                    HapticManager.shared.lightTap()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Menu {
                    ForEach(languages, id: \.self) { lang in
                        Button(lang) { targetLang = lang }
                    }
                } label: {
                    Text(targetLang)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .innerGlass(cornerRadius: 8)
                }
            }
            .padding(.horizontal, 14)
            
            // Input
            VStack(alignment: .leading, spacing: 4) {
                Text(sourceLang)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
                TextEditor(text: $inputText)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .frame(height: 60)
                    .padding(8)
                    .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 14)
            
            // Translate button
            Button {
                translate()
            } label: {
                HStack {
                    Image(systemName: "arrow.down")
                    Text("Translate")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.blue.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)
            
            // Output
            if !outputText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(targetLang)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                        Spacer()
                        Button {
                            // Copy to clipboard
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        
                        Button { } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text(outputText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 14)
            }
            
            // History
            if !history.isEmpty {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(Array(history.enumerated()), id: \.offset) { _, entry in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.source)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.5))
                                Text(entry.target)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                Text("\(entry.from) → \(entry.to)")
                                    .font(.system(size: 7))
                                    .foregroundStyle(.white.opacity(0.2))
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .innerGlass(cornerRadius: 6)
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            
            Spacer()
        }
    }
    
    private func translate() {
        guard !inputText.isEmpty else { return }
        // Simulated translations
        let translations: [String: [String: String]] = [
            "English": ["Spanish": "¡Traducción simulada!", "French": "Traduction simulée!", "German": "Simulierte Übersetzung!", "Japanese": "シミュレートされた翻訳！", "Korean": "시뮬레이션된 번역!"],
        ]
        outputText = translations[sourceLang]?[targetLang] ?? "[\(targetLang) translation of: \(inputText)]"
        history.insert((source: inputText, target: outputText, from: sourceLang, to: targetLang), at: 0)
        HapticManager.shared.success()
    }
}
