import SwiftUI

struct AuthView: View {
    @EnvironmentObject var telegram: TelegramService
    
    var body: some View {
        NavigationStack {
            Group {
                switch telegram.authState {
                case .loading, .waitingForTdlibParameters:
                    ProgressView("Загрузка...")
                case .waitingForPhoneNumber:
                    VStack(spacing: 16) {
                        Button(action: {
                            Task {
                                try? await telegram.requestQRCode()
                            }
                        }) {
                            Text("QR-код")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        NavigationLink(destination: PhoneEntryView()) {
                            Text("Номер телефона")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .navigationTitle("Вход")
                case .waitingForOtherDeviceConfirmation(let link):
                    QRCodeLoginView(link: link)
                case .waitingForCode(let codeInfo):
                    CodeEntryView(codeInfo: codeInfo)
                case .waitingForPassword(let hint):
                    PasswordEntryView(hint: hint)
                case .ready, .closed:
                    Text("Успешно")
                        .foregroundColor(.green)
                }
            }
            .overlay(
                Group {
                    if let error = telegram.currentError {
                        VStack {
                            Spacer()
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red.cornerRadius(8))
                                .padding(.bottom)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            )
        }
    }
}
