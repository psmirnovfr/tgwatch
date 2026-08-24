import AppIntents

struct TGWatchShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendTelegramMessageIntent(),
            phrases: [
                "Напиши \(\.$recipient) в \(.applicationName)",
                "Отправь сообщение \(\.$recipient) в \(.applicationName)",
                "Напиши в \(.applicationName) для \(\.$recipient)",
                "Отправь сообщение через \(.applicationName)",
                "Напиши сообщение в \(.applicationName)"
            ],
            shortTitle: "Написать в Telegram",
            systemImageName: "paperplane.fill"
        )
    }
}
