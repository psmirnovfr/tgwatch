import Foundation
import SwiftUI

struct ChatItem: Identifiable, Equatable {
    let id: Int64
    var title: String
    var lastMessage: String
    var lastMessageDate: Date?
    var unreadCount: Int
    var isPrivate: Bool
    
    var avatarColor: Color {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .teal, .indigo]
        let index = abs(Int(id)) % colors.count
        return colors[index]
    }
    
    var initials: String {
        let parts = title.split(separator: " ")
        if parts.isEmpty {
            return "?"
        } else if parts.count == 1 {
            return String(parts[0].prefix(2)).uppercased()
        } else {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }
    }
    
    var formattedTime: String {
        guard let date = lastMessageDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
