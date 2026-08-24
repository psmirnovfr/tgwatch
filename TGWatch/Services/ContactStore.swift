import Foundation

struct CachedContact: Codable, Identifiable {
    let id: Int64
    let name: String
}

/// Thread-safe contact cache for Siri entity queries.
/// Not isolated to @MainActor so AppIntents EntityStringQuery can access it synchronously.
final class ContactStore: @unchecked Sendable {
    static let shared = ContactStore()
    
    private let cacheKey = "tg_contacts_cache"
    private let queue = DispatchQueue(label: "com.tgwatch.contactstore", attributes: .concurrent)
    private var contacts: [CachedContact] = []
    
    private init() {
        loadFromCache()
    }
    
    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode([CachedContact].self, from: data) else {
            return
        }
        self.contacts = decoded
    }
    
    private func saveToCache() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    @MainActor
    func refreshFromTelegram() async {
        do {
            let telegramContacts = try await TelegramService.shared.searchContacts(query: "")
            
            // Also include recent chats as "contacts" for Siri resolution
            let recentChats = TelegramService.shared.chats
                .filter { $0.isPrivate }
                .map { (id: $0.id, name: $0.title) }
            
            var contactDict = [Int64: String]()
            
            // Merge existing cache
            queue.sync {
                for c in contacts {
                    contactDict[c.id] = c.name
                }
            }
            
            // Add TDLib contacts
            for tc in telegramContacts {
                contactDict[tc.id] = tc.name
            }
            
            // Add recent private chats
            for rc in recentChats {
                contactDict[rc.id] = rc.name
            }
            
            let newContacts = contactDict.map { CachedContact(id: $0.key, name: $0.value) }
            queue.async(flags: .barrier) { [weak self] in
                self?.contacts = newContacts
                self?.saveToCache()
            }
        } catch {
            print("Failed to refresh contacts: \(error)")
        }
    }
    
    func getAllContacts() -> [(id: Int64, name: String)] {
        queue.sync {
            contacts.map { ($0.id, $0.name) }
        }
    }
    
    func searchContacts(matching query: String) -> [(id: Int64, name: String)] {
        let lowerQuery = query.lowercased()
        return queue.sync {
            contacts
                .filter { $0.name.lowercased().contains(lowerQuery) }
                .map { ($0.id, $0.name) }
        }
    }
    
    func getRecentContacts() -> [(id: Int64, name: String)] {
        queue.sync {
            Array(contacts.prefix(10)).map { ($0.id, $0.name) }
        }
    }
}
