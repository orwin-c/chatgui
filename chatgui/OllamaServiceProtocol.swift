
import Foundation

protocol OllamaServiceable {
    func generateResponse(model: String, prompt: String) async throws -> OllamaResponse
}
