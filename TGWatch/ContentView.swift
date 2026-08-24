import SwiftUI

struct ContentView: View {
    @EnvironmentObject var telegram: TelegramService
    
    var body: some View {
        Group {
            if telegram.isLoggedIn {
                ChatListView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut, value: telegram.isLoggedIn)
    }
}
