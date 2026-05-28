// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Voice Memos Content

/// Voice recorder with waveform visualization, recording list, and playback.
struct VoiceMemosContent: View {
    
    @State private var isRecording = false
    @State private var recordingDuration = 0
    @State private var waveformValues: [CGFloat] = Array(repeating: 0.1, count: 40)
    @State private var memos: [VoiceMemo] = VoiceMemo.defaults
    @State private var playingMemoId: UUID?
    
    struct VoiceMemo: Identifiable {
        let id = UUID()
        var title: String
        var duration: String
        var date: String
        var waveform: [CGFloat]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.red)
                Text("Voice Memos")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            if isRecording {
                recordingView
            }
            
            // Memos list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(memos) { memo in
                        memoRow(memo)
                    }
                }
                .padding(.horizontal, 14)
            }
            
            Spacer()
            
            // Record button
            HStack {
                Spacer()
                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isRecording ? .red : .red.opacity(0.8))
                            .frame(width: 52, height: 52)
                        
                        if isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: 18, height: 18)
                        } else {
                            Circle()
                                .fill(.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .shadow(color: .red.opacity(isRecording ? 0.4 : 0), radius: 10)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.bottom, 14)
        }
        .onDisappear {
            recordingTimer?.invalidate()
            recordingTimer = nil
            waveformTimer?.invalidate()
            waveformTimer = nil
        }
    }
    
    // MARK: - Recording View
    
    private var recordingView: some View {
        VStack(spacing: 8) {
            // Waveform
            HStack(alignment: .center, spacing: 1.5) {
                ForEach(0..<40, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.red.opacity(0.7))
                        .frame(width: 3, height: waveformValues[i] * 40 + 2)
                }
            }
            .frame(height: 50)
            
            // Timer
            Text(formatTime(recordingDuration))
                .font(.system(size: 18, weight: .light, design: .monospaced))
                .foregroundStyle(.red)
        }
        .padding(14)
        .innerGlass(cornerRadius: 12)
        .padding(.horizontal, 14)
    }
    
    private func memoRow(_ memo: VoiceMemo) -> some View {
        let isPlaying = playingMemoId == memo.id
        
        return HStack(spacing: 10) {
            Button {
                playingMemoId = isPlaying ? nil : memo.id
                HapticManager.shared.lightTap()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(width: 30, height: 30)
                    .background(.red.opacity(0.15), in: Circle())
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(memo.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text(memo.date)
                    Text("•")
                    Text(memo.duration)
                }
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.3))
                
                // Mini waveform
                HStack(spacing: 1) {
                    ForEach(0..<20, id: \.self) { i in
                        let idx = i < memo.waveform.count ? i : 0
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(isPlaying ? .red.opacity(0.6) : .white.opacity(0.12))
                            .frame(width: 2, height: memo.waveform[idx] * 12 + 1)
                    }
                }
                .frame(height: 14)
            }
            
            Spacer()
            
            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .innerGlass(cornerRadius: 10)
    }
    
    @State private var recordingTimer: Timer?
    @State private var waveformTimer: Timer?
    
    private func startRecording() {
        isRecording = true
        recordingDuration = 0
        animateWaveform()
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingDuration += 1
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        waveformTimer?.invalidate()
        waveformTimer = nil
        let memo = VoiceMemo(
            title: "Recording \(memos.count + 1)",
            duration: formatTime(recordingDuration),
            date: "Just now",
            waveform: (0..<20).map { _ in CGFloat.random(in: 0.1...0.9) }
        )
        memos.insert(memo, at: 0)
        HapticManager.shared.success()
    }
    
    private func animateWaveform() {
        waveformTimer?.invalidate()
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard isRecording else {
                waveformTimer?.invalidate()
                waveformTimer = nil
                return
            }
            withAnimation(.easeInOut(duration: 0.1)) {
                for i in 0..<40 {
                    waveformValues[i] = CGFloat.random(in: 0.05...0.95)
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

extension VoiceMemosContent.VoiceMemo {
    static var defaults: [VoiceMemosContent.VoiceMemo] {
        [
            .init(title: "HoloDesk Pitch Notes", duration: "2:34", date: "Today", waveform: (0..<20).map { _ in CGFloat.random(in: 0.1...0.8) }),
            .init(title: "Meeting Summary", duration: "5:12", date: "Yesterday", waveform: (0..<20).map { _ in CGFloat.random(in: 0.1...0.8) }),
            .init(title: "Design Ideas", duration: "1:45", date: "May 10", waveform: (0..<20).map { _ in CGFloat.random(in: 0.1...0.8) }),
        ]
    }
}
