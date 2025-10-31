import Foundation

protocol OllamaServiceable {
    func generateResponse(model: String, prompt: String) async throws -> OllamaResponse
    func streamResponse(model: String, prompt: String) -> AsyncThrowingStream<OllamaResponse, Error>
}
