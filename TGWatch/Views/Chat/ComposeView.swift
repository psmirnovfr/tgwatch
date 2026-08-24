import SwiftUI

struct ComposeView: View {
    @Binding var isPresented: Bool
    let chatId: Int64
    let onSent: () -> Void
    
    @EnvironmentObject var telegram: TelegramService
    @State private var messageText: String = ""
    @State private var isSending = false
    @State private var errorText: String?
    
    var body: some View {
        VStack(spacing: 8) {
            TextField("Сообщение...", text: $messageText)
                .disabled(isSending)
            
            if let errorText = errorText {
                Text(errorText)
                    .foregroundColor(.red)
                    .font(.caption2)
            }
            
            Button(action: {
                Task {
                    await sendMessage()
                }
            }) {
                if isSending {
                    ProgressView()
                } else {
                    Label("Отправить", systemImage: "paperplane.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding()
    }
    
    private func sendMessage() async {
        isSending = true
        errorText = nil
        do {
            try await telegram.sendMessage(chatId: chatId, text: messageText)
            isSending = false
            isPresented = false
            onSent()
        } catch {
            errorText = "Ошибка отправки"
            isSending = false
        }
    }
}
