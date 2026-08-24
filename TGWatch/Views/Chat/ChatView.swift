import SwiftUI

struct ChatView: View {
    @EnvironmentObject var telegram: TelegramService
    let chatId: Int64
    let chatTitle: String
    
    @State private var messages: [MessageItem] = []
    @State private var isLoading = true
    @State private var showCompose = false
    @State private var errorText: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let errorText = errorText {
                Text(errorText)
                    .foregroundColor(.red)
                    .font(.caption)
            } else {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(spacing: 8) {
                            ForEach(messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 4)
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                        .onAppear {
                            if let last = messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(chatTitle)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: { showCompose = true }) {
                    Label("Написать", systemImage: "pencil")
                }
            }
        }
        .task {
            await loadMessages()
        }
        .sheet(isPresented: $showCompose) {
            ComposeView(isPresented: $showCompose, chatId: chatId) {
                Task {
                    await loadMessages()
                }
            }
        }
    }
    
    private func loadMessages() async {
        isLoading = true
        do {
            let history = try await telegram.getChatHistory(chatId: chatId, limit: 50)
            messages = history.sorted(by: { $0.date < $1.date })
            errorText = nil
        } catch {
            errorText = "Ошибка загрузки"
        }
        isLoading = false
    }
}
