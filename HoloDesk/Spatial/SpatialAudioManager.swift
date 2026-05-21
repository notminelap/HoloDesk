// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import AVFoundation
import Observation

// MARK: - Sound Effect Types

public enum SoundEffect: Sendable {
    case tap            // Short organic high-frequency pluck
    case windowOpen     // Sweeping synthesizer tone ascending
    case windowClose    // Sweeping synthesizer tone descending
    case aiActivate     // Dual-tone harmonic chime
    case success        // Pentatonic major chord arpeggio
    case error          // Low dissonant alert
    case chime          // Soft environmental chime
}

// MARK: - Spatial Audio Manager

/// Manages positional audio for spatial windows and environment effects.
/// Replaces traditional static audio assets with real-time mathematical sound synthesis.
@Observable
final class SpatialAudioManager {
    
    var isMuted = false
    var masterVolume: Float = 0.7
    var isAmbientPlaying = false
    
    private var audioEngine: AVAudioEngine?
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var environmentNode: AVAudioEnvironmentNode?
    
    init() {
        setupAudioEngine()
    }
    
    // MARK: - Setup
    
    private func setupAudioEngine() {
        let engine = AVAudioEngine()
        let environment = AVAudioEnvironmentNode()
        
        engine.attach(environment)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        
        // Set listener at origin (user's head position)
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0, 0, 0)
        
        // Reverb for spatial feel
        environment.reverbParameters.enable = true
        environment.reverbParameters.level = 15
        environment.reverbParameters.loadFactoryReverbPreset(.mediumRoom)
        
        self.audioEngine = engine
        self.environmentNode = environment
    }
    
    // MARK: - Window Audio Position
    
    /// Set the 3D position for a window's audio source.
    func setAudioPosition(windowId: UUID, position: SIMD3<Float>) {
        guard let node = playerNodes[windowId] else { return }
        node.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
    }
    
    /// Attach an audio source to a window.
    func attachAudioToWindow(windowId: UUID, position: SIMD3<Float>) {
        guard let engine = audioEngine, let environment = environmentNode else { return }
        
        let player = AVAudioPlayerNode()
        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        player.reverbBlend = 0.3
        player.renderingAlgorithm = .HRTFHQ
        
        engine.attach(player)
        engine.connect(player, to: environment, format: nil)
        
        playerNodes[windowId] = player
    }
    
    /// Remove audio source for a window.
    func detachAudioFromWindow(windowId: UUID) {
        guard let engine = audioEngine, let node = playerNodes[windowId] else { return }
        node.stop()
        engine.detach(node)
        playerNodes.removeValue(forKey: windowId)
    }
    
    // MARK: - Spatial Sound Effects (Dynamic Synthesis)
    
    /// Plays a mathematically synthesized sound effect spatialized in 3D environment space.
    func playSFX(_ effect: SoundEffect, at position: SIMD3<Float> = SIMD3<Float>(0, 0, -1.0)) {
        guard let engine = audioEngine, let environment = environmentNode, !isMuted else { return }
        
        if !engine.isRunning {
            startEngine()
        }
        
        let player = AVAudioPlayerNode()
        player.renderingAlgorithm = .HRTFHQ
        player.reverbBlend = 0.25
        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        
        engine.attach(player)
        engine.connect(player, to: environment, format: nil)
        
        guard let buffer = SoundBufferGenerator.generate(for: effect) else {
            engine.detach(player)
            return
        }
        
        player.scheduleBuffer(buffer, at: nil, options: []) {
            // Clean up player after completion to avoid memory and node leaks
            Task { @MainActor in
                player.stop()
                engine.detach(player)
            }
        }
        player.play()
    }
    
    // MARK: - Volume
    
    func setVolume(_ volume: Float) {
        masterVolume = max(0, min(1, volume))
        audioEngine?.mainMixerNode.outputVolume = isMuted ? 0 : masterVolume
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioEngine?.mainMixerNode.outputVolume = isMuted ? 0 : masterVolume
    }
    
    // MARK: - Start / Stop
    
    func startEngine() {
        guard let engine = audioEngine, !engine.isRunning else { return }
        do {
            try engine.start()
            isAmbientPlaying = true
        } catch {
            HoloDeskLogger.audio.error("Audio engine failed: \(error.localizedDescription)")
        }
    }
    
    func stopEngine() {
        audioEngine?.stop()
        isAmbientPlaying = false
    }
}

// MARK: - Sound Buffer Generator

/// Generates professional-grade PCM waveforms on the fly using DSP.
fileprivate enum SoundBufferGenerator {
    
    static func generate(for effect: SoundEffect, sampleRate: Double = 44100.0) -> AVAudioPCMBuffer? {
        let duration: Double
        switch effect {
        case .tap:          duration = 0.06
        case .windowOpen:   duration = 0.25
        case .windowClose:  duration = 0.20
        case .aiActivate:   duration = 0.35
        case .success:      duration = 0.40
        case .error:        duration = 0.30
        case .chime:        duration = 0.50
        }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let data = buffer.floatChannelData?[0] else { return nil }
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            var sample = 0.0
            
            switch effect {
            case .tap:
                // Elegant mechanical drop pluck (sine sweep + rapid decay)
                let freq = 900.0 * exp(-20.0 * t)
                let env = exp(-35.0 * t)
                sample = sin(2.0 * .pi * freq * t) * env * 0.45
                
            case .windowOpen:
                // Smooth spatial sweep ascending + resonance harmonics
                let freq = 220.0 + (330.0 * (t / duration))
                let env = sin(.pi * (t / duration)) * exp(-3.0 * t)
                sample = sin(2.0 * .pi * freq * t) * env * 0.30
                // Overlay organic chime highlight
                let chimeFreq = 1200.0
                let chimeEnv = exp(-40.0 * t) * 0.15
                sample += sin(2.0 * .pi * chimeFreq * t) * chimeEnv
                
            case .windowClose:
                // Soft natural descending sweep
                let freq = 550.0 - (300.0 * (t / duration))
                let env = exp(-6.0 * (t / duration)) * 0.35
                sample = sin(2.0 * .pi * freq * t) * env
                
            case .aiActivate:
                // Futuristic double chime arpeggio (C5 to G5 with high resonant glow)
                let c5 = 523.25
                let g5 = 783.99
                let env = sin(.pi * (t / duration)) * exp(-4.0 * t) * 0.35
                sample = (sin(2.0 * .pi * c5 * t) + sin(2.0 * .pi * g5 * t)) * env
                
            case .success:
                // Pentatonic major chord cascade arpeggio (C5 -> E5 -> G5 -> C6)
                let noteDur = 0.08
                var freq = 523.25
                if t > noteDur * 3 {
                    freq = 1046.50
                } else if t > noteDur * 2 {
                    freq = 783.99
                } else if t > noteDur {
                    freq = 659.25
                }
                let localT = t.truncatingRemainder(dividingBy: noteDur)
                let env = exp(-7.0 * localT) * 0.35
                sample = sin(2.0 * .pi * freq * t) * env
                
            case .error:
                // Double vibrato low buzz
                let freq = 180.0 + sin(2.0 * .pi * 50.0 * t) * 10.0
                let env = exp(-5.0 * t) * 0.40
                sample = sin(2.0 * .pi * freq * t) * env
                
            case .chime:
                // Environmental glass bell chime (E5)
                let freq = 659.25
                let env = exp(-2.5 * t) * 0.30
                sample = sin(2.0 * .pi * freq * t) * env
            }
            
            data[i] = Float(sample)
        }
        
        return buffer
    }
}
