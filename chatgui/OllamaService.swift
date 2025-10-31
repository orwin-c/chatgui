import Foundation

// MARK: - Ollama Service for handling API communication

class OllamaService: ObservableObject, OllamaServiceable {
    private let session = URLSession.shared
    private let url = URL(string: "http://localhost:11434/api/generate")!

    func streamResponse(model: String, prompt: String) -> AsyncThrowingStream<OllamaResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let requestPayload = OllamaRequest(model: model, prompt: prompt)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try? JSONEncoder().encode(requestPayload)
                
                do {
                    let (bytes, response) = try await session.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw OllamaError.invalidResponse
                    }
                    
                    for try await line in bytes.lines {
                        if let data = line.data(using: .utf8),
                           let ollamaResponse = try? JSONDecoder().decode(OllamaResponse.self, from: data) {
                            continuation.yield(ollamaResponse)
                            
                            if ollamaResponse.done {
                                continuation.finish()
                                return
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func generateResponse(model: String, prompt: String) async throws -> OllamaResponse {
        let requestPayload = OllamaRequest(model: model, prompt: prompt)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestPayload)
        
        let (bytes, response) = try await session.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OllamaError.invalidResponse
        }
        
        var lastResponse: OllamaResponse?
        for try await line in bytes.lines {
            if let data = line.data(using: .utf8),
               let ollamaResponse = try? JSONDecoder().decode(OllamaResponse.self, from: data) {
                lastResponse = ollamaResponse
                if ollamaResponse.done {
                    break
                }
            }
        }
        if let lastResponse = lastResponse {
            return lastResponse
        } else {
            throw OllamaError.invalidResponse
        }
    }
}

// MARK: - API Data Structures

/// The JSON payload to send to the Ollama /api/generate endpoint.
struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool = true
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
