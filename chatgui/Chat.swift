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
    var content: String
    let date: Date
}

// 1. Define your Chat model
struct Chat: Identifiable, Hashable {
    // Your chat properties here, for example:
    let id = UUID()
    var messages: [Message] = []
    var title: String
}


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
