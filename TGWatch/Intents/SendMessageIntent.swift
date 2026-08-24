import AppIntents

struct SendTelegramMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Отправить сообщение в Telegram"
    static var description = IntentDescription("Отправляет текстовое сообщение контакту в Telegram")
    
    // When Siri can't resolve, it asks "Кому отправить сообщение?"
    @Parameter(title: "Получатель", requestValueDialog: IntentDialog("Кому отправить сообщение?"))
    var recipient: TelegramContactEntity
    
    // When message not provided, Siri asks "Что написать?"
    @Parameter(title: "Текст сообщения", requestValueDialog: IntentDialog("Что написать?"))
    var message: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Отправить \(\.$message) для \(\.$recipient)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard TelegramService.shared.isLoggedIn else {
            throw IntentError.notLoggedIn
        }
        try await TelegramService.shared.sendMessage(chatId: recipient.id, text: message)
        return .result(dialog: "Сообщение отправлено \(recipient.name)")
    }
}

enum IntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case notLoggedIn
    case sendFailed
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notLoggedIn:
            return "Сначала войдите в TGWatch"
        case .sendFailed:
            return "Не удалось отправить сообщение"
        }
    }
}
