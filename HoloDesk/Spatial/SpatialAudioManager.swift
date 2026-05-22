// ─────────────────────────────────────────────────────────────────────────────
//                S P A T I A L   A U D I O   S Y N T H E S I Z E R
// ─────────────────────────────────────────────────────────────────────────────
//   HoloDesk Dynamic Positional DSP Sound Engine - visionOS 2.0+
//
//   Copyright (c) 2027 Radhesh Ranvijay. All Rights Reserved.
//   Designed and engineered by Radhesh Ranvijay for Apple Swift Student Challenge.
// ─────────────────────────────────────────────────────────────────────────────


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
    case bubblePop      // Quick organic pop sound (pop!)
    case cosmicSweep    // Sweeping cinematic riser/whoosh
    case softTick       // Mechanical click/tick sound
    case sonarPing      // High sonar ticking click
    case scanComplete   // Synthesized sparkling chord swell
    case buddySpawn     // Magical atmospheric spatial chime sweep
}

// MARK: - Spatial Audio Manager

/// Manages positional audio for spatial windows and environment effects.
/// Replaces traditional static audio assets with real-time mathematical sound synthesis.
@Observable
final class SpatialAudioManager {
    
    var isMuted = false
    var masterVolume: Float = 0.7
    var isAmbientPlaying = false
    var store: WorkspaceStore?
    
    private var audioEngine: AVAudioEngine?
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var environmentNode: AVAudioEnvironmentNode?
    
    // Procedural ambient drone properties
    private var ambientSourceNode: AVAudioSourceNode?
    private var isDroneActive = false
    
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
    
    // MARK: - Generative Ambient Drone
    
    /// Starts a real-time generative warm atmospheric synthesizer pad.
    /// Synthesized dynamically via mathematical formulas with detuned oscillators.
    func startAmbientDrone() {
        guard let engine = audioEngine, let environment = environmentNode, !isDroneActive, !isMuted else { return }
        
        if !engine.isRunning {
            startEngine()
        }
        
        isDroneActive = true
        
        var phase1: Double = 0
        var phase2: Double = 0
        var phase3: Double = 0
        var lfoPhase: Double = 0
        
        let sourceNode = AVAudioSourceNode { [weak self] (silence, timestamp, frameCount, outputData) -> OSStatus in
            guard let self = self, self.isDroneActive else { return 0 }
            let abl = UnsafeMutableAudioBufferListPointer(outputData)
            guard let buffer = abl.first else { return 0 }
            let data = buffer.mData?.assumingMemoryBound(to: Float.self)
            
            let sampleRate = 44100.0
            
            for frame in 0..<Int(frameCount) {
                // LFO for volume/detune modulation (0.04 Hz)
                lfoPhase += 2.0 * .pi * 0.04 / sampleRate
                let lfoVal = 0.5 + 0.5 * sin(lfoPhase)
                let detune = 0.3 * sin(lfoPhase * 0.4)
                
                // Oscillator 1: F2 (87.31 Hz)
                phase1 += 2.0 * .pi * 87.31 / sampleRate
                let osc1 = sin(phase1)
                
                // Oscillator 2: C3 (130.81 Hz) with detune
                phase2 += 2.0 * .pi * (130.81 + detune) / sampleRate
                let osc2 = sin(phase2)
                
                // Oscillator 3: F3 (174.61 Hz)
                phase3 += 2.0 * .pi * 174.61 / sampleRate
                let osc3 = sin(phase3)
                
                // Combined warm chord: F2 minor-seventh/sus4 hybrid (F-C-F)
                let mix = (osc1 * 0.5 + osc2 * 0.35 + osc3 * 0.15 * lfoVal) * 0.10 * self.masterVolume
                
                data?[frame] = Float(mix)
            }
            
            return 0
        }
        
        engine.attach(sourceNode)
        
        // Connect to environment for high-quality spatialization
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
        engine.connect(sourceNode, to: environment, format: format)
        
        // Position drone above the workspace
        sourceNode.position = AVAudio3DPoint(x: 0, y: 2.5, z: -1.0)
        sourceNode.reverbBlend = 0.85 // High reverb blend for atmospheric space
        sourceNode.renderingAlgorithm = .HRTFHQ
        
        self.ambientSourceNode = sourceNode
        isAmbientPlaying = true
        
        HoloDeskLogger.audio.info("Dynamic generative ambient drone started")
    }
    
    /// Stops the generative ambient drone.
    func stopAmbientDrone() {
        guard isDroneActive, let engine = audioEngine, let node = ambientSourceNode else { return }
        isDroneActive = false
        node.stop()
        engine.detach(node)
        self.ambientSourceNode = nil
        isAmbientPlaying = false
        HoloDeskLogger.audio.info("Dynamic generative ambient drone stopped")
    }
    
    // MARK: - Volume
    
    func setVolume(_ volume: Float) {
        masterVolume = max(0, min(1, volume))
        audioEngine?.mainMixerNode.outputVolume = isMuted ? 0 : masterVolume
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioEngine?.mainMixerNode.outputVolume = isMuted ? 0 : masterVolume
        if isMuted {
            stopAmbientDrone()
        } else if store?.isImmersiveSpaceOpen == true {
            startAmbientDrone()
        }
    }
    
    // MARK: - Start / Stop
    
    func startEngine() {
        guard let engine = audioEngine, !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            HoloDeskLogger.audio.error("Audio engine failed: \(error.localizedDescription)")
        }
    }
    
    func stopEngine() {
        stopAmbientDrone()
        audioEngine?.stop()
    }
    
    // MARK: - Procedural Keyboard Wave Synthesizer
    
    enum WaveType: String, CaseIterable, Codable {
        case sine = "Sine"
        case triangle = "Triangle"
        case square = "Square"
        case sawtooth = "Sawtooth"
    }
    
    /// Mathematically synthesizes an oscillator wave in 3D environment space with a clickless envelope.
    func playTone(frequency: Double, waveType: WaveType, duration: Double, at position: SIMD3<Float> = SIMD3<Float>(0, 0, -1.0)) {
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
        
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            engine.detach(player)
            return
        }
        buffer.frameLength = frameCount
        
        guard let data = buffer.floatChannelData?[0] else {
            engine.detach(player)
            return
        }
        
        // Attack envelope (5ms) & Decay envelope (50ms)
        let attackFrames = Int(0.005 * sampleRate)
        let decayFrames = Int(0.050 * sampleRate)
        let totalFrames = Int(frameCount)
        
        for i in 0..<totalFrames {
            let t = Double(i) / sampleRate
            var sample = 0.0
            
            let period = 1.0 / frequency
            let cycleProgress = (t.truncatingRemainder(dividingBy: period)) / period
            
            switch waveType {
            case .sine:
                sample = sin(2.0 * .pi * frequency * t)
            case .triangle:
                if cycleProgress < 0.5 {
                    sample = -1.0 + 4.0 * cycleProgress
                } else {
                    sample = 3.0 - 4.0 * cycleProgress
                }
            case .square:
                sample = cycleProgress < 0.5 ? 1.0 : -1.0
            case .sawtooth:
                sample = -1.0 + 2.0 * cycleProgress
            }
            
            // Envelope modulation
            var amplitude = 0.35
            if i < attackFrames {
                let factor = Double(i) / Double(attackFrames)
                amplitude *= factor
            } else if i > totalFrames - decayFrames {
                let factor = Double(totalFrames - i) / Double(decayFrames)
                amplitude *= factor
            }
            
            data[i] = Float(sample * amplitude)
        }
        
        player.scheduleBuffer(buffer, at: nil, options: []) {
            Task { @MainActor in
                player.stop()
                engine.detach(player)
            }
        }
        player.play()
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
        case .bubblePop:    duration = 0.08
        case .cosmicSweep:  duration = 0.80
        case .softTick:     duration = 0.04
        case .sonarPing:    duration = 0.22
        case .scanComplete: duration = 0.60
        case .buddySpawn:   duration = 0.90
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
                
            case .bubblePop:
                // Rapid frequency upward pitch sweep + steep decay (waterdrop pop!)
                let freq = 400.0 + (1800.0 * (t / duration))
                let env = exp(-35.0 * t) * (1.0 - t / duration)
                sample = sin(2.0 * .pi * freq * t) * env * 0.35
                
            case .cosmicSweep:
                // A massive organic cinematic swoosh (riser whoosh)
                let f1 = 120.0 + 380.0 * (t / duration)
                let f2 = 122.0 + 390.0 * (t / duration)
                let f3 = 240.0 + 760.0 * (t / duration)
                let env = sin(.pi * (t / duration)) * exp(-1.5 * t) * 0.22
                sample = (sin(2.0 * .pi * f1 * t) + sin(2.0 * .pi * f2 * t) * 0.8 + sin(2.0 * .pi * f3 * t) * 0.5) * env
                
            case .softTick:
                // High-precision clean mechanical click
                let freq = 1800.0 * exp(-100.0 * t)
                let env = exp(-85.0 * t)
                sample = sin(2.0 * .pi * freq * t) * env * 0.20
                
            case .sonarPing:
                // Sonar radar sweep ping (sine sweep + resonance chime)
                let freq = 1300.0 * exp(-15.0 * t)
                let env = exp(-9.0 * t)
                sample = sin(2.0 * .pi * freq * t) * env * 0.30
                
            case .scanComplete:
                // Sparkling major pentatonic upward swell (C6 -> E6 -> G6 -> C7)
                let noteDur = 0.08
                var freq = 1046.50
                if t > noteDur * 3 {
                    freq = 2093.00
                } else if t > noteDur * 2 {
                    freq = 1567.98
                } else if t > noteDur {
                    freq = 1318.51
                }
                let localT = t.truncatingRemainder(dividingBy: noteDur)
                let env = exp(-6.0 * localT) * 0.35
                sample = sin(2.0 * .pi * freq * t) * env
                
            case .buddySpawn:
                // Shimmering chime drone with a deep whoosh
                let f1 = 100.0 + 250.0 * (t / duration)
                let f2 = 880.0
                let env = sin(.pi * (t / duration)) * exp(-2.5 * t) * 0.30
                sample = (sin(2.0 * .pi * f1 * t) * 0.5 + sin(2.0 * .pi * f2 * t) * 0.8) * env
            }
            
            data[i] = Float(sample)
        }
        
        return buffer
    }
}
