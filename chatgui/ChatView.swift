import SwiftUI

struct ChatView: View {
    @ObservedObject private var viewModel: ChatViewModel
    @Binding var isRelevant: Bool
    @EnvironmentObject var chatManager: ChatManager

    // Pass the specific chat for this screen
    init(chat: Chat, service: OllamaServiceable, isRelevant: Binding<Bool>) {
        let chat = chat
        let service = service
        let isRelevant = isRelevant
        self._isRelevant = isRelevant
        self.viewModel = ChatViewModel(chat: chat, ollamaService: service, isRelevant: isRelevant)
    }
    
    var body: some View {
        VStack {
            // Messages area
            ScrollViewReader {proxy in
                ScrollView {
                    ZStack (alignment: .topTrailing){
                        if (viewModel.chat.messages.isEmpty != false) {
                            Menu {
                                ForEach(viewModel.chat.messages) { message in
                                    if message.role == .user {
                                        Button(message.content) {
                                            proxy.scrollTo(message.id, anchor: .top)
                                        }
                                    }
                                }
                            } label: {
                                Text("History")
                                    .font(Font.custom("SF Pro Display", size: 15).weight(.medium))
                                    .padding([.leading, .trailing], 10)
                                    .padding([.top, .bottom], 8)
                                    .solidMaterial(cornerRadius: 3.0)
                            }
                            .buttonStyle(.plain)
                            
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.chat.messages) { message in
                                HStack {
                                    if message.role == .user {
                                        Spacer()
                                        Text(message.content)
                                            .padding(10)
                                            .background(Color.blue.opacity(0.15))
                                            .cornerRadius(10)
                                    } else {
                                        Text(message.content)
                                            .padding(10)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                        Spacer()
                                    }
                                }
                                .id(message.id)
                                .animation(.default, value: viewModel.chat.messages.count)
                            }
                        }
                        .padding()
                        
                    }
                }
                
            }
        
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            ZStack(alignment: .bottom) {
                if viewModel.isLoading {
                    HStack {
                        Text("Model is thinking...")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                
                VStack {
                    if (isRelevant == false) {
                        AlignmentNotifView(visible: .constant(true), isRelevant: $isRelevant)
                        
                    }
                    HStack {
                        TextField("Ask a question...", text: $viewModel.prompt, axis: .vertical)
                            .font(Font.custom("SF Pro Display", size: 14))
                            .textFieldStyle(.plain)
                            .onSubmit {
                                Task {
                                    await viewModel.sendMessage()
                                }
                            }
                            .padding(.leading, 12)

                        Button {
                            Task {
                                await viewModel.sendMessage()
                            }
                        } label: {
                            Image(systemName: "arrow.up")
                                .foregroundStyle(Color("White"))
                                .frame(width: 30, height: 30)
                                .background(Color("Black"))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading || viewModel.prompt.isEmpty)
                    }
                    .padding(8)
                    .solidMaterial(cornerRadius: 1000.0)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5), value: viewModel.isLoading)
                    
                }
                
        
        }
        .padding(10)
        .background(Color("WhiteBG"))
        .toolbar {
            ToolbarItem() {
                Button {
                    let newChat = Chat(title: "New Chat")
                    chatManager.addChat(newChat)
                    chatManager.selectedChatID = newChat.id
                    
                    
                } label: {
                    Image(systemName: "plus")
                }
                .solidMaterial(cornerRadius: 1000.0)
            }
        }
    }
}

// Example preview
#Preview {
    let chat = Chat(title: "Demo Chat")
    return ChatView(chat: chat, service: MockOllamaService(), isRelevant: .constant(true))
        .environmentObject(ChatManager())
}
