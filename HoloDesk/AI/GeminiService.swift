// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation

// MARK: - Gemini API Service

/// Production Gemini API client for HoloDesk AI.
/// Handles streaming, context management, and spatial workspace intelligence.
actor GeminiService {
    
    static let shared = GeminiService()
    
    /// API key loaded from environment — NEVER hardcode keys in source.
    /// Set via: Xcode Scheme → Run → Arguments → Environment Variables → GEMINI_API_KEY
    private let apiKey: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    private let model = "gemini-2.0-flash"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    /// Conversation history for context
    private var conversationHistory: [GeminiMessage] = []
    
    /// System prompt that defines HoloDesk AI personality
    private let systemPrompt = """
    You are HoloDesk AI — a spatial computing assistant built into HoloDesk, \
    a premium workspace platform for Apple Vision Pro. You are helpful, concise, \
    and enthusiastic about spatial computing.
    
    Your capabilities:
    - Switch workspace modes: work, study, cinema, gaming
    - Open window types: messages, calendar, notes, music, photos, files, weather, \
      todo, video, browser, whiteboard, spotify, podcast, kanban, mindMap, codeEditor, \
      terminal, meditation, visualizer, modelViewer, ambienceMixer, facetime, stocks, \
      habits, translator, clipboard, chess, mail, voiceMemos, spreadsheet, systemMonitor, \
      socialFeed, colorPicker
    - Save/load workspaces
    - Rearrange windows (arc layout, grid, etc.)
    - Open immersive 3D space
    - Provide productivity tips and spatial computing advice
    
    When the user wants to perform an action, respond with a helpful message AND \
    include an action tag in your response using this format:
    [ACTION:switch_mode:work] or [ACTION:add_window:notes] or [ACTION:save] or \
    [ACTION:rearrange] or [ACTION:immersive] or [ACTION:clear]
    
    Keep responses SHORT (1-2 sentences max) and spatial-themed. Use emojis sparingly.
    You were built by Notminelap Industries.
    """
    
    // MARK: - API Types
    
    struct GeminiMessage: Codable {
        let role: String  // "user" or "model"
        let parts: [GeminiPart]
    }
    
    struct GeminiPart: Codable {
        let text: String
    }
    
    struct GeminiRequest: Codable {
        let contents: [GeminiMessage]
        let systemInstruction: GeminiMessage?
        let generationConfig: GenerationConfig?
    }
    
    struct GenerationConfig: Codable {
        let temperature: Double?
        let topP: Double?
        let maxOutputTokens: Int?
    }
    
    struct GeminiResponse: Codable {
        let candidates: [Candidate]?
        let error: GeminiError?
    }
    
    struct Candidate: Codable {
        let content: GeminiMessage?
        let finishReason: String?
    }
    
    struct GeminiError: Codable {
        let message: String?
        let code: Int?
    }
    
    // MARK: - Chat
    
    /// Send a message to Gemini and get a response with full conversation context.
    func chat(message: String, workspaceContext: String? = nil) async throws -> String {
        // Build user message with optional workspace context
        var userText = message
        if let context = workspaceContext {
            userText += "\n\n[Current workspace state: \(context)]"
        }
        
        // Add to history
        let userMessage = GeminiMessage(role: "user", parts: [GeminiPart(text: userText)])
        conversationHistory.append(userMessage)
        
        // Keep last 20 messages for context window
        if conversationHistory.count > 20 {
            conversationHistory = Array(conversationHistory.suffix(20))
        }
        
        // Build request
        let request = GeminiRequest(
            contents: conversationHistory,
            systemInstruction: GeminiMessage(role: "user", parts: [GeminiPart(text: systemPrompt)]),
            generationConfig: GenerationConfig(
                temperature: 0.7,
                topP: 0.9,
                maxOutputTokens: 256
            )
        )
        
        // Make API call
        let urlString = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiServiceError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 15
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiServiceError.apiError(code: httpResponse.statusCode, message: errorText)
        }
        
        let decoder = JSONDecoder()
        let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw GeminiServiceError.apiError(code: error.code ?? 0, message: error.message ?? "Unknown")
        }
        
        guard let responseText = geminiResponse.candidates?.first?.content?.parts.first?.text else {
            throw GeminiServiceError.emptyResponse
        }
        
        // Add assistant response to history
        let assistantMessage = GeminiMessage(role: "model", parts: [GeminiPart(text: responseText)])
        conversationHistory.append(assistantMessage)
        
        return responseText
    }
    
    /// Quick one-shot query (no conversation history)
    func quickQuery(_ prompt: String) async throws -> String {
        let request = GeminiRequest(
            contents: [GeminiMessage(role: "user", parts: [GeminiPart(text: prompt)])],
            systemInstruction: nil,
            generationConfig: GenerationConfig(temperature: 0.5, topP: 0.8, maxOutputTokens: 150)
        )
        
        let urlString = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiServiceError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 10
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        return response.candidates?.first?.content?.parts.first?.text ?? "I couldn't process that."
    }
    
    /// Reset conversation context
    func resetConversation() {
        conversationHistory.removeAll()
    }
    
    // MARK: - Workspace Context Builder
    
    /// Builds a context string from current workspace state for smarter responses
    static func buildContext(from store: WorkspaceStore) -> String {
        let windowNames = store.activeWindows.map { $0.type.displayName }.joined(separator: ", ")
        let mode = store.currentMode.displayName
        let count = store.activeWindows.count
        return "Mode: \(mode), Windows(\(count)): \(windowNames)"
    }
}

// MARK: - Errors

enum GeminiServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResponse
    case apiError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid response from Gemini"
        case .emptyResponse: return "Gemini returned an empty response"
        case .apiError(let code, let message): return "API Error \(code): \(message)"
        }
    }
}
