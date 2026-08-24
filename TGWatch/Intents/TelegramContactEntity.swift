import AppIntents

struct TelegramContactEntity: AppEntity {
    static var defaultQuery = TelegramContactQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Контакт Telegram")
    
    let id: Int64
    let name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}
