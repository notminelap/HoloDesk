// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Speech
import AVFoundation
import Observation

// MARK: - Voice Command Manager

@MainActor @Observable
final class VoiceCommandManager {
    var isAuthorized = false
    var isListening = false
    var transcript = ""
    var lastCommand = ""
    
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private weak var currentStore: WorkspaceStore?
    private weak var currentWindowManager: WindowManager?
    
    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        // @Sendable: TCC invokes this on a background queue; without it the closure
        // inherits @MainActor isolation and the Swift 6 runtime check traps off-main.
        SFSpeechRecognizer.requestAuthorization { @Sendable status in
            Task { @MainActor in
                self.isAuthorized = (status == .authorized)
            }
        }
    }
    
    // MARK: - Start / Stop
    
    @MainActor
    func startListening(store: WorkspaceStore, windowManager: WindowManager) {
        guard isAuthorized, !isListening else { return }
        
        currentStore = store
        currentWindowManager = windowManager
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // The tap fires on the audio render thread; append is documented thread-safe,
        // so opt the request out of the Sendable capture check.
        nonisolated(unsafe) let tapRequest = request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { @Sendable buffer, _ in
            tapRequest.append(buffer)
        }
        
        recognitionTask = recognizer?.recognitionTask(with: request) { @Sendable [weak self] result, error in
            guard let self else { return }
            if let result {
                let text = result.bestTranscription.formattedString.lowercased()
                Task { @MainActor in
                    self.transcript = text
                    self.currentStore?.voiceTranscript = text
                    self.processCommand(text)
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in
                    self.stopListening()
                }
            }
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            store.isListening = true
        } catch {
            HoloDeskLogger.audio.error("Audio engine failed to start: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
        currentStore?.isListening = false
        currentStore?.voiceTranscript = ""
    }
    
    // MARK: - Command Processing
    
    @MainActor
    private func processCommand(_ text: String) {
        let commands: [(keywords: [String], action: () -> Void)] = [
            (["open work mode", "work mode", "switch to work"],
             { self.switchMode(.work) }),
            (["open study mode", "study mode", "switch to study"],
             { self.switchMode(.study) }),
            (["open cinema mode", "cinema mode", "movie mode"],
             { self.switchMode(.cinema) }),
            (["open gaming mode", "gaming mode", "game mode"],
             { self.switchMode(.gaming) }),
            (["save workspace", "save layout", "save current"],
             { self.currentStore?.saveCurrentWorkspace() }),
            (["reset workspace", "clear all", "reset all"],
             { self.currentStore?.clearAllWindows() }),
            (["add notes", "open notes"],
             { guard let s = self.currentStore else { return }; self.currentWindowManager?.spawnWindow(type: .notes, in: s) }),
            (["add calendar", "open calendar"],
             { guard let s = self.currentStore else { return }; self.currentWindowManager?.spawnWindow(type: .calendar, in: s) }),
            (["add music", "open music", "play music"],
             { guard let s = self.currentStore else { return }; self.currentWindowManager?.spawnWindow(type: .music, in: s) }),
            (["add messages", "open messages"],
             { guard let s = self.currentStore else { return }; self.currentWindowManager?.spawnWindow(type: .messages, in: s) }),
        ]
        
        for command in commands {
            if command.keywords.contains(where: { text.contains($0) }) {
                if lastCommand != text {
                    lastCommand = text
                    command.action()
                }
                break
            }
        }
    }
    
    @MainActor
    private func switchMode(_ mode: WorkspaceMode) {
        guard let store = currentStore, let manager = currentWindowManager else { return }
        Task {
            await manager.transitionToMode(mode, in: store)
        }
    }
}
