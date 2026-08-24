import SwiftUI

struct ChatRowView: View {
    let chat: ChatItem
    
    var body: some View {
        HStack(spacing: 8) {
            // Avatar
            Circle()
                .fill(chat.avatarColor)
                .frame(width: 35, height: 35)
                .overlay {
                    Text(chat.initials)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(chat.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(chat.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer(minLength: 4)
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}
