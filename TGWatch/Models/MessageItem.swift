import Foundation

enum ContentType {
    case text
    case photo
    case video
    case document
    case sticker
    case voiceNote
    case other
}

struct MessageItem: Identifiable, Equatable {
    let id: Int64
    let text: String
    let isOutgoing: Bool
    let date: Date
    let senderName: String
    let contentType: ContentType
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var displayText: String {
        switch contentType {
        case .text:
            return text
        case .photo:
            return "[Фото]"
        case .video:
            return "[Видео]"
        case .document:
            return "[Документ]"
        case .sticker:
            return "[Стикер]"
        case .voiceNote:
            return "[Голосовое сообщение]"
        case .other:
            return "[Вложение]"
        }
    }
}
