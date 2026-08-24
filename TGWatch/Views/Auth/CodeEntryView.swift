import SwiftUI

struct CodeEntryView: View {
    @EnvironmentObject var telegram: TelegramService
    let codeInfo: String
    
    @State private var code: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(codeInfo)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                TextField("Код", text: $code)
                    .textContentType(.oneTimeCode)
                
                Button(action: submit) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Подтвердить")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(isLoading || code.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Введите код")
    }
    
    private func submit() {
        isLoading = true
        Task {
            do {
                try await telegram.checkCode(code)
            } catch {
                // Error handled in service and shown in parent AuthView overlay
            }
            isLoading = false
        }
    }
}
