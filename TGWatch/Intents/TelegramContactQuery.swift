import AppIntents

struct TelegramContactQuery: EntityStringQuery {
    func entities(for identifiers: [TelegramContactEntity.ID]) async throws -> [TelegramContactEntity] {
        let contacts = ContactStore.shared.getAllContacts()
        return contacts
            .filter { identifiers.contains($0.id) }
            .map { TelegramContactEntity(id: $0.id, name: $0.name) }
    }
    
    func entities(matching string: String) async throws -> [TelegramContactEntity] {
        let contacts = ContactStore.shared.searchContacts(matching: string)
        return contacts.map { TelegramContactEntity(id: $0.id, name: $0.name) }
    }
    
    func suggestedEntities() async throws -> [TelegramContactEntity] {
        let contacts = ContactStore.shared.getRecentContacts()
        return contacts.map { TelegramContactEntity(id: $0.id, name: $0.name) }
    }
}
