import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var telegram: TelegramService
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Group {
                if telegram.chats.isEmpty && isLoading {
                    ProgressView()
                } else if telegram.chats.isEmpty {
                    Text("Нет чатов")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(telegram.chats) { chat in
                            NavigationLink(destination: ChatView(chatId: chat.id, chatTitle: chat.title)) {
                                ChatRowView(chat: chat)
                            }
                        }
                    }
                    .refreshable {
                        await loadChats()
                    }
                }
            }
            .navigationTitle("Чаты")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .task {
                await loadChats()
            }
        }
    }
    
    private func loadChats() async {
        isLoading = true
        await telegram.loadChats()
        isLoading = false
    }
}
