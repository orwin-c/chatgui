
import Foundation

// MARK: - Ollama Service for handling API communication

class OllamaService: ObservableObject, OllamaServiceable {
    private let session = URLSession.shared
    private let url = URL(string: "http://localhost:11434/api/generate")!

    // MARK: - Public Interface

    /// Generates a response from the Ollama API in a non-streaming fashion.
    /// - Parameters:
    ///   - model: The name of the model to use (e.g., "llava:7b").
    ///   - prompt: The text prompt to send to the model.
    /// - Returns: The complete generated response.
    /// - Throws: An error if the network request or JSON decoding fails.
    func generateResponse(model: String, prompt: String) async throws -> OllamaResponse {
        let requestPayload = OllamaRequest(model: model, prompt: prompt)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestPayload)
        } catch {
            throw OllamaError.encodingFailed(error)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OllamaError.invalidResponse
        }
        
        do {
            let ollamaResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
            return ollamaResponse
        } catch {
            throw OllamaError.decodingFailed(error)
        }
    }
}

// MARK: - API Data Structures

/// The JSON payload to send to the Ollama /api/generate endpoint.
struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool = false // We'll stick to non-streaming for simplicity first
}

/// The JSON response from the Ollama /api/generate endpoint.
struct OllamaResponse: Codable {
    let model: String
    let createdAt: String
    let response: String
    let done: Bool
    
    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response
        case done
    }
}

// MARK: - Custom Errors

enum OllamaError: Error, LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode the request: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        }
    }
}
