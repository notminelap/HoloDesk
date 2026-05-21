// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Onboarding View (WWDC Quality)

/// First-launch onboarding — cinematic introduction to HoloDesk.
/// Each page has animated icon reveal, parallax background, and smooth transitions.
struct OnboardingView: View {
    
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @State private var pageAppeared = false
    @State private var iconPhase: Double = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🧊",
            title: "Welcome to HoloDesk",
            subtitle: "Your Room Is Your Computer",
            description: "Place windows, files, and tools anywhere in your physical space. Your workspace persists across sessions — come back to exactly where you left off.",
            icon: "cube.transparent",
            gradient: [
                Color(hue: 0.6, saturation: 0.7, brightness: 0.7),
                Color(hue: 0.65, saturation: 0.5, brightness: 0.4)
            ]
        ),
        OnboardingPage(
            emoji: "🪟",
            title: "Spatial Windows",
            subtitle: "Apps Float in Your Space",
            description: "Messages, Calendar, Notes, Spotify, Code Editor — 32 built-in apps, each a floating glass panel you can grab and arrange with your hands.",
            icon: "macwindow.on.rectangle",
            gradient: [
                Color(hue: 0.8, saturation: 0.6, brightness: 0.65),
                Color(hue: 0.85, saturation: 0.4, brightness: 0.35)
            ]
        ),
        OnboardingPage(
            emoji: "🖐️",
            title: "Hand Tracking",
            subtitle: "Reach Out and Grab",
            description: "Use natural hand gestures to move windows, pinch to interact, and shape your workspace. Zero controllers, zero tutorials — it just works.",
            icon: "hand.raised.fill",
            gradient: [
                Color(hue: 0.15, saturation: 0.6, brightness: 0.7),
                Color(hue: 0.1, saturation: 0.4, brightness: 0.35)
            ]
        ),
        OnboardingPage(
            emoji: "🎯",
            title: "Workspace Modes",
            subtitle: "One Tap, Total Transformation",
            description: "Work, Study, Cinema, Gaming — switch modes and your entire room transforms. Windows rearrange, lighting adapts, ambience changes.",
            icon: "square.stack.3d.up",
            gradient: [
                Color(hue: 0.35, saturation: 0.6, brightness: 0.6),
                Color(hue: 0.4, saturation: 0.4, brightness: 0.3)
            ]
        ),
        OnboardingPage(
            emoji: "🤖",
            title: "Gemini AI",
            subtitle: "Your Spatial Intelligence",
            description: "Powered by Google Gemini — ask anything, control your workspace with natural language, and let AI suggest optimal layouts for your workflow.",
            icon: "sparkles",
            gradient: [
                Color(hue: 0.55, saturation: 0.7, brightness: 0.8),
                Color(hue: 0.7, saturation: 0.5, brightness: 0.4)
            ]
        ),
    ]
    
    struct OnboardingPage {
        let emoji: String
        let title: String
        let subtitle: String
        let description: String
        let icon: String
        let gradient: [Color]
    }
    
    var body: some View {
        ZStack {
            // Animated background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 340)
                
                // Progress indicators
                progressDots
                    .padding(.vertical, 14)
                
                // Navigation
                navigationBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        }
        .frame(width: 520, height: 480)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .glassBackground(cornerRadius: 36, shadowRadius: 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { pageAppeared = true }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                iconPhase = .pi * 2
            }
        }
        .scaleEffect(pageAppeared ? 1 : 0.9)
        .opacity(pageAppeared ? 1 : 0)
    }
    
    // MARK: - Background Gradient
    
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient that shifts per page
            LinearGradient(
                colors: pages[currentPage].gradient.map { $0.opacity(0.15) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.6), value: currentPage)
            
            // Radial glow
            RadialGradient(
                colors: [
                    pages[currentPage].gradient[0].opacity(0.1),
                    .clear
                ],
                center: .init(x: 0.5, y: 0.3),
                startRadius: 20,
                endRadius: 300
            )
            .animation(.easeInOut(duration: 0.6), value: currentPage)
        }
    }
    
    // MARK: - Onboarding Page
    
    private func onboardingPage(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 18) {
            Spacer()
            
            // Animated icon orb
            ZStack {
                // Rotating halo
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: page.gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(currentPage == index ? iconPhase * 180 / .pi : 0))
                
                // Glow backing
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.gradient[0].opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)
                
                // Glass circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .fill(page.gradient[0].opacity(0.2))
                    .frame(width: 72, height: 72)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, page.gradient[0].opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Specular
                Ellipse()
                    .fill(
                        LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center)
                    )
                    .frame(width: 40, height: 16)
                    .offset(y: -22)
                    .blur(radius: 1)
            }
            
            // Emoji
            Text(page.emoji)
                .font(.system(size: 24))
            
            // Title
            Text(page.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // Subtitle
            Text(page.subtitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: page.gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Description
            Text(page.description)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 36)
            
            Spacer()
        }
    }
    
    // MARK: - Progress Dots
    
    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage
                          ? LinearGradient(colors: pages[index].gradient, startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: index == currentPage ? 20 : 7, height: 7)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack(spacing: 16) {
            // Skip button
            if currentPage < pages.count - 1 {
                Button {
                    withAnimation(.spatialTransition) {
                        isOnboardingComplete = true
                        UserDefaults.standard.set(true, forKey: "holodesk_onboarding_complete")
                    }
                } label: {
                    Text("Skip")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Back
            if currentPage > 0 {
                Button {
                    withAnimation(.spatialMove) { currentPage -= 1 }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .bold))
                        Text("Back")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .innerGlass(cornerRadius: 14)
                }
                .buttonStyle(.plain)
            }
            
            // Next / Get Started
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.spatialMove) { currentPage += 1 }
                    HapticManager.shared.selectionChanged()
                } else {
                    withAnimation(.spatialTransition) {
                        isOnboardingComplete = true
                        UserDefaults.standard.set(true, forKey: "holodesk_onboarding_complete")
                    }
                    HapticManager.shared.success()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Enter HoloDesk")
                    Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: pages[currentPage].gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .shadow(color: pages[currentPage].gradient[0].opacity(0.3), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
}
