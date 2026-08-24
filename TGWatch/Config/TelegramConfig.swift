import Foundation

enum TelegramConfig {
    // User must fill these in from my.telegram.org
    static let apiId: Int32 = 0 // TODO: Replace with your api_id
    static let apiHash: String = "" // TODO: Replace with your api_hash
    
    static let appVersion = "1.0.0"
    static let deviceModel = "Apple Watch"
    static let systemLanguageCode = "ru"
    static let applicationVersion = "1.0"
    
    // Database paths
    static var databaseDirectory: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("tdlib").path
    }
    
    static var filesDirectory: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("tdlib_files").path
    }
}
