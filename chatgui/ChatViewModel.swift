import Foundation
import SwiftUI
import FoundationModels


@MainActor
class ChatViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var prompt: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Binding var isRelevant: Bool
    var model = SystemLanguageModel.default
    
    // The chat this ViewModel manages
    @Published var chat: Chat
    
    private let ollamaService: OllamaServiceable
    private let modelToUse = "llava:7b"

    init(chat: Chat, ollamaService: OllamaServiceable, isRelevant: Binding<Bool>) {
        self.chat = chat
        self.ollamaService = ollamaService
        self._isRelevant = isRelevant
    }

    // MARK: - Public Interface
    
    func generateTitle(userMessage: String) async -> String {
        let session = LanguageModelSession()
        let quick = "Wrtie a concise title which encapsulates what the user is asking. The title should be at most 5 words long (excluding articles). For this chat, the user's first message was: \(userMessage)."
        do {
            let response = try await session.respond(to: quick)
            return response.content
        } catch {
            return "New Chat"
        }

    }
    
    func checkRelevance() async -> Void {
        print("Validation model called")
        let instructions = """
            You are a validation model. You must respond ONLY with `true` or `false`. No punctuation, no extra words.
            """
        let session = LanguageModelSession(instructions: instructions)
        let quick = "Output `true` or `false` based on whether the user's message is relevant to the topic of this chat. The user's latest message was \(chat.messages.last!.content) and their other messages were: \(chat.messages.filter { $0.role == .user })"
        do {
            let response = try await session.respond(to: quick)
            if (response.content == "false") {
                isRelevant = false
            } else {
                isRelevant = true
            }
        } catch {
            isRelevant = true
        }

    }
    
    
    func sendMessage() async {
        guard !prompt.isEmpty else { return }
        let userText = prompt
        prompt = "" // clear input
        errorMessage = nil
        isLoading = true
        
        
        // 1) Save the user's message into this chat
        let userMessage = Message(role: .user, content: userText, date: Date())
        chat.messages.append(userMessage)
        if case .available = model.availability {
            if (chat.messages.count == 1) {
                let userMessages = chat.messages.filter { $0.role == .user }
                let title = await generateTitle(userMessage: userMessages[0].content)
                chat.title = title
                
            }
            await checkRelevance()
            
            
        }
        
        
        
        // 2) Ask the model for a response
        Task {
            do {
                // 1) Create the assistant message once, initially empty
                let assistantMessage = Message(role: .assistant, content: "", date: Date())
                chat.messages.append(assistantMessage)
                
                // 2) Stream and append to the same message
                for try await chunk in ollamaService.streamResponse(model: modelToUse, prompt: userText) {
                    // Find and update the last message (the assistant message we just added)
                    if let index = chat.messages.lastIndex(where: { $0.id == assistantMessage.id }) {
                        chat.messages[index].content += chunk.response
                    }
                }
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "An unknown error occurred."
            }
            self.isLoading = false
        }
    }
}

