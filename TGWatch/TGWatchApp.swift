import SwiftUI

@main
struct TGWatchApp: App {
    @StateObject private var telegramService = TelegramService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telegramService)
        }
    }
}
