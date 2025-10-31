//
//  ContentView.swift
//  chatgui
//
//  Created by Owen Cheng on 9/7/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedChatID: UUID?
    @EnvironmentObject var chatManager: ChatManager
    @State var isRelevant: Bool = true

    var body: some View {
        return ZStack(alignment: .topLeading) {
                    let service: OllamaServiceable = OllamaService()


            NavigationSplitView {
                Button(action: { chatManager.addChat(Chat(title: "New Chat")) }) {
                    Text("Add Chat")
                }
                List(selection: $chatManager.selectedChatID) {
                    ForEach(chatManager.chatHistory) { chat in
                        NavigationLink(value: chat.id) {
                            Text(chat.title)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                chatManager.removeChat(withID: chat.id)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("Chats")
                .frame(maxWidth: 200)
            } detail: {
                if let selectedChat = chatManager.selectedChat {
                    ChatView(chat: selectedChat, service: service, isRelevant: $isRelevant)
                } else {
                    Text("Select a chat")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .background(.ultraThinMaterial)
    }

}

#Preview {
    let chatManager = ChatManager()
    ContentView()
        .environmentObject(chatManager)
}
