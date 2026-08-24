import SwiftUI

struct PasswordEntryView: View {
    @EnvironmentObject var telegram: TelegramService
    let hint: String
    
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if !hint.isEmpty {
                    Text("Подсказка: \(hint)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                SecureField("Пароль", text: $password)
                
                Button(action: submit) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Войти")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(isLoading || password.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Облачный пароль")
    }
    
    private func submit() {
        isLoading = true
        Task {
            do {
                try await telegram.checkPassword(password)
            } catch {
                // Error handled in service and shown in parent AuthView overlay
            }
            isLoading = false
        }
    }
}
