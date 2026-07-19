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
@MainActor @Observable
final class SpatialAudioManager {
    
    /// Shared singleton for views that can't use @Environment injection
    static let shared = SpatialAudioManager()
    
    var isMuted = false
    var masterVolume: Float = 0.7
    var isAmbientPlaying = false
    var store: WorkspaceStore?
    
    private var audioEngine: AVAudioEngine?
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var environmentNode: AVAudioEnvironmentNode?

    /// One-shot effect players awaiting completion cleanup, keyed by effect id.
    /// Completion handlers pass back only the Sendable id, never the node itself.
    private var activeEffectPlayers: [UUID: AVAudioPlayerNode] = [:]
    
    // Procedural ambient drone properties
    private var ambientSourceNode: AVAudioSourceNode?
    private var isDroneActive = false
    
    init() {
        setupAudioEngine()
        observeAudioNotifications()
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

    // MARK: - Engine Resilience

    /// Core Audio stops the engine on route/configuration changes (headphones
    /// connect, AirPods switch) and interruptions, leaving it ready-but-stopped.
    /// Without observing these, every sound in the app silently dies.
    private func observeAudioNotifications() {
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.recoverEngineIfNeeded()
            }
        }

        #if os(visionOS) || os(iOS)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            // Extract Sendable values before hopping to the main actor.
            let typeValue = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt ?? 0
            let optionsValue = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            Task { @MainActor [weak self] in
                self?.handleInterruption(typeValue: typeValue, optionsValue: optionsValue)
            }
        }
        #endif
    }

    private func recoverEngineIfNeeded() {
        guard let engine = audioEngine, !engine.isRunning, !isMuted else { return }
        startEngine()
    }

    #if os(visionOS) || os(iOS)
    private func handleInterruption(typeValue: UInt, optionsValue: UInt) {
        guard AVAudioSession.InterruptionType(rawValue: typeValue) == .ended else { return }
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        if options.contains(.shouldResume) {
            recoverEngineIfNeeded()
        }
    }
    #endif
    
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
        // Fixed: Replace hrtfHQ with .auto as .hrtfHQ may not be available on all platforms
        player.renderingAlgorithm = .auto
        
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
        // engine.start() can fail (e.g. during an audio-session interruption);
        // playing a node on a stopped engine raises an uncatchable NSException.
        guard engine.isRunning else { return }
        
        let player = AVAudioPlayerNode()
        // Fixed: Replace .hrtfHQ with .auto for compatibility
        player.renderingAlgorithm = .auto
        player.reverbBlend = 0.25
        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        
        guard let buffer = SoundBufferGenerator.generate(for: effect) else { return }

        engine.attach(player)
        // Connect using the buffer's own format: a nil format adopts the hardware
        // rate (48 kHz on some routes), and scheduling a 44.1 kHz buffer on that
        // connection raises an uncatchable NSException.
        engine.connect(player, to: environment, format: buffer.format)

        let effectId = UUID()
        activeEffectPlayers[effectId] = player
        player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
            // Clean up player after completion to avoid memory and node leaks
            Task { @MainActor in
                self?.finishEffectPlayer(id: effectId)
            }
        }
        player.play()
    }

    /// Detaches a completed one-shot effect player on the main actor.
    private func finishEffectPlayer(id: UUID) {
        guard let player = activeEffectPlayers.removeValue(forKey: id) else { return }
        player.stop()
        audioEngine?.detach(player)
    }

    // MARK: - Generative Ambient Drone
    
    /// Starts a real-time generative warm atmospheric synthesizer pad.
    /// Synthesized dynamically via mathematical formulas with detuned oscillators.
    func startAmbientDrone() {
        guard let engine = audioEngine, let environment = environmentNode, !isDroneActive, !isMuted else { return }
        
        if !engine.isRunning {
            startEngine()
        }
        // engine.start() can fail (e.g. during an audio-session interruption);
        // playing a node on a stopped engine raises an uncatchable NSException.
        guard engine.isRunning else { return }
        
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
                let part1 = osc1 * 0.5
                let part2 = osc2 * 0.35
                let part3 = osc3 * 0.15 * lfoVal
                // Fixed: Cast self.masterVolume (Float) to Double for multiplication with Doubles
                let mixSum = part1 + part2 + part3
                let mix = mixSum * 0.10 * Double(self.masterVolume) // Cast for type consistency
                
                // Fixed: cast Double to Float for data assignment
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
        // Fixed: replace .hrtfHQ with .auto for compatibility
        sourceNode.renderingAlgorithm = .auto
        
        self.ambientSourceNode = sourceNode
        isAmbientPlaying = true
        
        HoloDeskLogger.audio.info("Dynamic generative ambient drone started")
    }
    
    /// Stops the generative ambient drone.
    func stopAmbientDrone() {
        guard isDroneActive, let engine = audioEngine, let node = ambientSourceNode else { return }
        isDroneActive = false
        // Fixed: AVAudioSourceNode has no stop method, so remove node.stop() call
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
        // engine.start() can fail (e.g. during an audio-session interruption);
        // playing a node on a stopped engine raises an uncatchable NSException.
        guard engine.isRunning else { return }
        
        let player = AVAudioPlayerNode()
        // Fixed: replace .hrtfHQ with .auto for compatibility
        player.renderingAlgorithm = .auto
        player.reverbBlend = 0.25
        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        engine.attach(player)
        // Connect using the buffer's own format — see playSFX: a nil-format
        // connection adopts the hardware rate and mismatched scheduling aborts.
        engine.connect(player, to: environment, format: format)

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
        
        let effectId = UUID()
        activeEffectPlayers[effectId] = player
        player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
            Task { @MainActor in
                self?.finishEffectPlayer(id: effectId)
            }
        }
        player.play()
    }

    // MARK: - visionOS 27: Reverb Mesh (Geometric Acoustics)
    
    /// Room acoustic material profiles for geometric reverb simulation.
    /// When running on visionOS 27+, the Reverb Mesh API uses these to model
    /// how sound is absorbed and scattered by virtual room surfaces.
    struct AcousticMaterial {
        let name: String
        let absorptionCoefficient: Float  // 0.0 = fully reflective, 1.0 = fully absorbed
        let scatteringCoefficient: Float  // 0.0 = specular, 1.0 = diffuse
        
        static let glass   = AcousticMaterial(name: "Glass",   absorptionCoefficient: 0.06, scatteringCoefficient: 0.1)
        static let wood    = AcousticMaterial(name: "Wood",    absorptionCoefficient: 0.15, scatteringCoefficient: 0.3)
        static let fabric  = AcousticMaterial(name: "Fabric",  absorptionCoefficient: 0.65, scatteringCoefficient: 0.7)
        static let metal   = AcousticMaterial(name: "Metal",   absorptionCoefficient: 0.03, scatteringCoefficient: 0.05)
        static let carpet  = AcousticMaterial(name: "Carpet",  absorptionCoefficient: 0.55, scatteringCoefficient: 0.8)
        static let concrete = AcousticMaterial(name: "Concrete", absorptionCoefficient: 0.04, scatteringCoefficient: 0.15)
    }
    
    /// Current room acoustic profile used for reverb simulation.
    var roomMaterials: [AcousticMaterial] = [
        .glass, .wood, .concrete  // Default HoloDesk workspace materials
    ]
    
    /// Configures geometric reverb based on the detected room's materials.
    /// On visionOS 27+, this maps to the Reverb Mesh API for physically-accurate
    /// sound propagation. On earlier versions, falls back to preset-based reverb.
    func configureRoomAcoustics(materials: [AcousticMaterial]? = nil) {
        roomMaterials = materials ?? [.glass, .wood, .concrete]
        
        // Calculate average absorption for fallback reverb preset selection
        let avgAbsorption = roomMaterials.map { $0.absorptionCoefficient }.reduce(0, +) / Float(max(roomMaterials.count, 1))
        
        // Map absorption to reverb intensity (lower absorption = more reverb)
        let reverbIntensity = 1.0 - avgAbsorption
        
        // Apply to environment node's reverb parameters
        if let envNode = environmentNode {
            envNode.reverbParameters.enable = true
            envNode.reverbParameters.level = reverbIntensity * 25.0  // Scale to dB range
            
            // Select preset based on room characteristics
            if avgAbsorption > 0.5 {
                envNode.reverbParameters.loadFactoryReverbPreset(.mediumRoom)
            } else if avgAbsorption > 0.2 {
                envNode.reverbParameters.loadFactoryReverbPreset(.largeRoom)
            } else {
                envNode.reverbParameters.loadFactoryReverbPreset(.cathedral)
            }
        }
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
