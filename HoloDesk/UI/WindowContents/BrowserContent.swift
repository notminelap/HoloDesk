// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Browser Window Content

/// Safari-style web browser window.
struct BrowserContent: View {
    @State private var urlText = "https://holodesk.app"
    @State private var isLoading = false
    
    private let tabs = ["HoloDesk", "Apple Dev", "GitHub"]
    @State private var activeTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        tabButton(tab, index: index)
                    }
                    
                    Button { } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .background(.black.opacity(0.15))
            
            // URL bar
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.green)
                    
                    Text(urlText)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .innerGlass(cornerRadius: 8)
                
                // Reload
                Button {
                    isLoading = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        isLoading = false
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Web page content (simulated)
            webContent
        }
    }
    
    private func tabButton(_ title: String, index: Int) -> some View {
        Button {
            activeTab = index
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                    .font(.system(size: 9))
                    .foregroundStyle(activeTab == index ? .holoPrimary : .white.opacity(0.3))
                
                Text(title)
                    .font(.system(size: 10, weight: activeTab == index ? .semibold : .regular))
                    .foregroundStyle(activeTab == index ? .white : .white.opacity(0.5))
                
                if activeTab == index {
                    Button { } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                activeTab == index
                ? Color.white.opacity(0.08)
                : Color.clear,
                in: RoundedRectangle(cornerRadius: 6)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var webContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Hero
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [.holoPrimary.opacity(0.3), .holoTertiary.opacity(0.2)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 80)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("🧊 HoloDesk")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Your Room Is Your Computer")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    )
                
                // Text blocks
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.06))
                                .frame(height: 8)
                                .frame(maxWidth: CGFloat.random(in: 150...300))
                        }
                    }
                }
            }
            .padding(12)
        }
    }
}


