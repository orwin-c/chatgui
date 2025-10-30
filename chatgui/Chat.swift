//
//  Chat.swift
//  chatgui
//
//  Created by Owen Cheng on 9/13/25.
//

import Foundation
import SwiftData

struct Message: Identifiable, Codable, Hashable {
    enum Role: String, Codable, Hashable {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let content: String
    let date: Date
}

// 1. Define your Chat model
struct Chat: Identifiable, Hashable {
    // Your chat properties here, for example:
    let id = UUID()
    var messages: [Message] = []
    var title: String
}

// 2. Create a class or struct to manage the list of chats
//class ChatManager: ObservableObject {
//    var selectedChat: Chat? {
//        chatHistory.first { $0.id == selectedChatID }
//    }
//    
//    @Published var selectedChatID: UUID? = nil
//    // This is the list that will hold all your Chat instances
//    @Published var chatHistory: [Chat] = []
//
//    // A method to add a new chat to the history
//    func addChat(_ newChat: Chat) {
//        chatHistory.append(newChat)
//    }
//    
//    init() {
//        // 1. First, populate the chat history
//        self.chatHistory = [
//            Chat(title: "SwiftUI Questions"),
//            Chat(title: "Project Ideas"),
//            Chat(title: "Groceries")
//        ]
//        // 2. Then, set the selectedChatID from the now-populated array
//        self.selectedChatID = self.chatHistory.first?.id
//    }
//}

class ChatManager: ObservableObject {
    @Published var selectedChatID: UUID? = nil
    @Published var chatHistory: [Chat] = []

    var selectedChat: Chat? {
        guard let selectedChatID = selectedChatID else { return nil }
        return chatHistory.first { $0.id == selectedChatID }
    }

    func addChat(_ newChat: Chat) {
        chatHistory.append(newChat)
    }
    func removeChat(withID id: UUID) {
        chatHistory.removeAll { $0.id == id }
        // If the removed chat was the selected one, clear the selection
        if selectedChatID == id {
            selectedChatID = nil
        }
    }

    init() {
        self.chatHistory = [
            Chat(title: "SwiftUI Questions"),
            Chat(title: "Project Ideas"),
            Chat(title: "Groceries")
        ]
        self.selectedChatID = self.chatHistory.first?.id
    }
}
