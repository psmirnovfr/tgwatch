import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject var telegram: TelegramService
    @State private var phoneNumber: String = "+"
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TextField("Номер", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
                
                Button(action: submit) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Далее")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(isLoading || phoneNumber.count < 5)
            }
            .padding()
        }
        .navigationTitle("Телефон")
    }
    
    private func submit() {
        isLoading = true
        Task {
            do {
                try await telegram.setPhoneNumber(phoneNumber)
            } catch {
                // Error handled in service and shown in parent AuthView overlay
            }
            isLoading = false
        }
    }
}
