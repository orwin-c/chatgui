
import Foundation

// MARK: - Mock Ollama Service for UI testing

class MockOllamaService: OllamaServiceable {
    func generateResponse(model: String, prompt: String) async throws -> OllamaResponse {
        // Simulate a network delay
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        
        
        // Return a canned response
        return OllamaResponse(
            model: model,
            createdAt: Date().ISO8601Format(),
            response: "This is a mock response for UI testing. The quick brown fox jumps over the lazy dog.",
            done: true
        )
    }
}
