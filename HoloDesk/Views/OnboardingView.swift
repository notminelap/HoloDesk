// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Onboarding View

/// First-launch onboarding — introduces HoloDesk's key concepts with stunning visuals.
struct OnboardingView: View {
    
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    private let pages: [(emoji: String, title: String, subtitle: String, description: String, icon: String)] = [
        (
            "🧊",
            "Welcome to HoloDesk",
            "Your Room Is Your Computer",
            "Place windows, files, and tools anywhere in your physical space. Return to the same workspace every day.",
            "cube.transparent"
        ),
        (
            "🪟",
            "Spatial Windows",
            "Apps Float in Your Space",
            "Messages, Calendar, Notes, Music — each lives as a floating glass panel you can grab and place anywhere.",
            "macwindow.on.rectangle"
        ),
        (
            "🖐️",
            "Hand Tracking",
            "Reach Out and Grab",
            "Use natural hand gestures to grab files, move windows, and interact with your workspace. No controllers needed.",
            "hand.raised.fill"
        ),
        (
            "🎯",
            "Workspace Modes",
            "One Tap, Total Transformation",
            "Switch between Work, Study, Cinema, and Gaming modes. Your room transforms instantly with beautiful animations.",
            "square.stack.3d.up"
        ),
        (
            "🤖",
            "AI Assistant",
            "Your Spatial Helper",
            "Just say what you need. \"Open work mode\" or \"Add notes\" — your AI assistant handles the rest.",
            "sparkles"
        ),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    onboardingPage(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 300)
            
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.holoPrimary : .white.opacity(0.2))
                        .frame(width: 7, height: 7)
                        .scaleEffect(index == currentPage ? 1.2 : 1)
                        .animation(.spatialInteract, value: currentPage)
                }
            }
            .padding(.vertical, 16)
            
            // Navigation buttons
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button {
                        withAnimation(.spatialMove) {
                            currentPage -= 1
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .innerGlass(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spatialMove) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.spatialTransition) {
                            isOnboardingComplete = true
                            UserDefaults.standard.set(true, forKey: "holodesk_onboarding_complete")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "arrow.right")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(LinearGradient.accentGradient, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 480, height: 420)
        .glassBackground(cornerRadius: 32)
    }
    
    private func onboardingPage(_ page: (emoji: String, title: String, subtitle: String, description: String, icon: String)) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Icon with glow
            ZStack {
                Circle()
                    .fill(LinearGradient.accentGradient.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(LinearGradient.accentGradient)
            }
            
            Text(page.emoji)
                .font(.system(size: 28))
            
            Text(page.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(page.subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.holoSecondary)
            
            Text(page.description)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
