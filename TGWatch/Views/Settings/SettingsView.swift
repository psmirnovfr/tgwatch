import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var telegram: TelegramService
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        List {
            Section(header: Text("Аккаунт")) {
                Button(role: .destructive) {
                    showingLogoutConfirmation = true
                } label: {
                    Text("Выйти")
                }
            }
            
            Section(header: Text("Siri")) {
                Text("Скажите: «Напиши [имя] в TGWatch»")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Section(header: Text("О приложении")) {
                Text("TGWatch v1.0.0")
                Text("watchOS Telegram клиент")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Настройки")
        .confirmationDialog("Вы уверены, что хотите выйти?", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
            Button("Выйти", role: .destructive) {
                Task {
                    try? await telegram.logout()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }
}
