import SwiftUI

struct MessageBubbleView: View {
    let message: MessageItem
    
    var body: some View {
        HStack {
            if message.isOutgoing {
                Spacer(minLength: 20)
            }
            
            VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 2) {
                if !message.isOutgoing && !message.senderName.isEmpty {
                    Text(message.senderName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Text(message.displayText)
                    .font(.body)
                    .foregroundColor(message.isOutgoing ? .white : .primary)
                    .multilineTextAlignment(.leading)
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(message.isOutgoing ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                message.isOutgoing ? Color.blue : Color(white: 0.2)
            )
            .cornerRadius(12)
            
            if !message.isOutgoing {
                Spacer(minLength: 20)
            }
        }
    }
}
