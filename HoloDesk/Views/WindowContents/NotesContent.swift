// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Notes Window Content

/// Design Ideas notes view — handwriting-style with bullet points and a decorative image.
struct NotesContent: View {
    
    private let ideas = [
        "minimalist",
        "natural light",
        "open space",
        "clean lines"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Notes")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }
            
            Divider().overlay(Color.white.opacity(0.08))
            
            // Title — styled like handwriting
            Text("Design Ideas")
                .font(.system(size: 24, weight: .light, design: .serif))
                .italic()
                .foregroundStyle(.white)
                .padding(.top, 4)
            
            // Decorative image placeholder (room interior)
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: 0.07, saturation: 0.3, brightness: 0.4),
                            Color(hue: 0.08, saturation: 0.25, brightness: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 100)
                .overlay(
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("Interior concept")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                )
            
            // Bullet points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(ideas, id: \.self) { idea in
                    HStack(spacing: 8) {
                        Text("–")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.4))
                        
                        Text(idea)
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .italic()
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(.top, 4)
            
            // Color palette dots
            HStack(spacing: 10) {
                ForEach([Color.blue, .teal, .brown, .orange, .yellow], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(16)
    }
}
