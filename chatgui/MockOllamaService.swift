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
    
    func streamResponse(model: String, prompt: String) -> AsyncThrowingStream<OllamaResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // Simulate streaming by yielding one chunk and then finishing
                    let response = OllamaResponse(
                        model: model,
                        createdAt: Date().ISO8601Format(),
                        response: "This is a mock streamed response for UI testing. The quick brown fox jumps over the lazy dog.",
                        done: true
                    )
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                    continuation.yield(response)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
