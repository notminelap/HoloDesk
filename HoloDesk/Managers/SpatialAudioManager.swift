// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import AVFoundation
import Observation

// MARK: - Spatial Audio Manager

/// Manages positional audio for spatial windows and environment effects.
/// Each window can have its own audio position in 3D space.
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
            print("Audio engine failed: \(error)")
        }
    }
    
    func stopEngine() {
        audioEngine?.stop()
        isAmbientPlaying = false
    }
}
