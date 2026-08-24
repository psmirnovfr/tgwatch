import Foundation
import SwiftUI
import TDLibKit

enum AuthState: Equatable {
    case loading
    case waitingForTdlibParameters
    case waitingForPhoneNumber
    case waitingForCode(codeInfo: String)
    case waitingForPassword(hint: String)
    case waitingForOtherDeviceConfirmation(link: String)
    case ready
    case closed
}

@MainActor
final class TelegramService: ObservableObject {
    static let shared = TelegramService()
    
    @Published var authState: AuthState = .loading
    @Published var chats: [ChatItem] = []
    @Published var isLoggedIn: Bool = false
    @Published var currentError: String?
    
    private var manager: TDLibClientManager?
    private var client: TDLibClient?
    private var refreshTimer: Timer?
    
    init() {
        manager = TDLibClientManager()
        client = manager?.createClient { [weak self] data, client in
            Task { @MainActor [weak self] in
                self?.handleUpdate(data, client: client)
            }
        }
    }
    
    private func handleUpdate(_ data: Data, client: TDLibClient) {
        do {
            let update = try client.decoder.decode(Update.self, from: data)
            switch update {
            case .updateAuthorizationState(let stateUpdate):
                handleAuthorizationState(stateUpdate.authorizationState)
            case .updateNewMessage, .updateChatLastMessage, .updateNewChat:
                Task { await loadChats() }
            default:
                break
            }
        } catch {
            // Not all updates map to the Update enum; silently ignore unknown types
        }
    }
    
    private func handleAuthorizationState(_ state: AuthorizationState) {
        switch state {
        case .authorizationStateWaitTdlibParameters:
            authState = .waitingForTdlibParameters
            Task { try? await setTdlibParameters() }
        case .authorizationStateWaitPhoneNumber:
            authState = .waitingForPhoneNumber
        case .authorizationStateWaitCode(let info):
            authState = .waitingForCode(codeInfo: info.codeInfo.phoneNumber)
        case .authorizationStateWaitPassword(let info):
            authState = .waitingForPassword(hint: info.passwordHint)
        case .authorizationStateWaitOtherDeviceConfirmation(let info):
            authState = .waitingForOtherDeviceConfirmation(link: info.link)
        case .authorizationStateReady:
            authState = .ready
            isLoggedIn = true
            currentError = nil
            startRefreshTimer()
            Task {
                await loadChats()
                await ContactStore.shared.refreshFromTelegram()
            }
        case .authorizationStateClosed:
            authState = .closed
            isLoggedIn = false
            stopRefreshTimer()
        default:
            authState = .loading
        }
    }
    
    private func setTdlibParameters() async throws {
        guard let client = client else { return }
        try await client.setTdlibParameters(
            apiHash: TelegramConfig.apiHash,
            apiId: TelegramConfig.apiId,
            applicationVersion: TelegramConfig.appVersion,
            databaseDirectory: TelegramConfig.databaseDirectory,
            databaseEncryptionKey: Data(),
            deviceModel: TelegramConfig.deviceModel,
            enableStorageOptimizer: true,
            filesDirectory: TelegramConfig.filesDirectory,
            ignoreFileNames: false,
            systemLanguageCode: TelegramConfig.systemLanguageCode,
            systemVersion: "watchOS",
            useChatInfoDatabase: true,
            useFileDatabase: false,
            useMessageDatabase: true,
            useSecretChats: false,
            useTestDc: false
        )
    }
    
    func requestQRCode() async throws {
        guard let client = client else { return }
        try await client.requestQrCodeAuthentication(otherUserIds: [])
    }
    
    func setPhoneNumber(_ phone: String) async throws {
        guard let client = client else { return }
        try await client.setAuthenticationPhoneNumber(phoneNumber: phone, settings: nil)
    }
    
    func checkCode(_ code: String) async throws {
        guard let client = client else { return }
        try await client.checkAuthenticationCode(code: code)
    }
    
    func checkPassword(_ password: String) async throws {
        guard let client = client else { return }
        try await client.checkAuthenticationPassword(password: password)
    }
    
    func loadChats() async {
        guard let client = client else { return }
        do {
            let chatListResult = try await client.getChats(chatList: .chatListMain, limit: 30)
            var newChats: [ChatItem] = []
            for chatId in chatListResult.chatIds {
                if let chat = try? await client.getChat(chatId: chatId), let item = convertChat(chat) {
                    newChats.append(item)
                }
            }
            self.chats = newChats
        } catch {
            currentError = error.localizedDescription
        }
    }
    
    func getChatHistory(chatId: Int64, limit: Int) async throws -> [MessageItem] {
        guard let client = client else { return [] }
        let messages = try await client.getChatHistory(
            chatId: chatId,
            fromMessageId: 0,
            limit: Int32(limit),
            offset: 0,
            onlyLocal: false
        )
        return messages.messages.compactMap { convertMessage($0) }
    }
    
    func sendMessage(chatId: Int64, text: String) async throws {
        guard let client = client else { return }
        let formattedText = FormattedText(entities: [], text: text)
        let content = InputMessageContent.inputMessageText(
            InputMessageText(
                clearDraft: true,
                linkPreviewOptions: nil,
                text: formattedText
            )
        )
        let _ = try await client.sendMessage(
            chatId: chatId,
            inputMessageContent: content,
            messageThreadId: 0,
            options: nil,
            replyTo: nil
        )
        await loadChats()
    }
    
    func searchContacts(query: String) async throws -> [(id: Int64, name: String)] {
        guard let client = client else { return [] }
        let result = try await client.searchContacts(limit: 50, query: query)
        var contacts: [(id: Int64, name: String)] = []
        for userId in result.userIds {
            if let user = try? await client.getUser(userId: userId) {
                let name = [user.firstName, user.lastName].filter { !$0.isEmpty }.joined(separator: " ")
                if !name.isEmpty {
                    contacts.append((id: userId, name: name))
                }
            }
        }
        return contacts
    }
    
    func logout() async throws {
        guard let client = client else { return }
        try await client.logOut()
    }
    
    func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                if self?.isLoggedIn == true {
                    await self?.loadChats()
                }
            }
        }
    }
    
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func convertChat(_ chat: Chat) -> ChatItem? {
        var lastMessageText = ""
        var lastMessageDate: Date? = nil
        if let msg = chat.lastMessage {
            lastMessageDate = Date(timeIntervalSince1970: TimeInterval(msg.date))
            switch msg.content {
            case .messageText(let textContent):
                lastMessageText = textContent.text.text
            case .messagePhoto:
                lastMessageText = "[Фото]"
            case .messageVideo:
                lastMessageText = "[Видео]"
            case .messageDocument:
                lastMessageText = "[Документ]"
            case .messageSticker:
                lastMessageText = "[Стикер]"
            case .messageVoiceNote:
                lastMessageText = "[Голосовое сообщение]"
            default:
                lastMessageText = "[Вложение]"
            }
        }
        
        let isPrivate: Bool
        if case .chatTypePrivate = chat.type {
            isPrivate = true
        } else {
            isPrivate = false
        }
        
        return ChatItem(
            id: chat.id,
            title: chat.title,
            lastMessage: lastMessageText,
            lastMessageDate: lastMessageDate,
            unreadCount: Int(chat.unreadCount),
            isPrivate: isPrivate
        )
    }
    
    private func convertMessage(_ message: Message) -> MessageItem? {
        var text = ""
        var contentType: ContentType = .other
        
        switch message.content {
        case .messageText(let textContent):
            text = textContent.text.text
            contentType = .text
        case .messagePhoto:
            contentType = .photo
        case .messageVideo:
            contentType = .video
        case .messageDocument:
            contentType = .document
        case .messageSticker:
            contentType = .sticker
        case .messageVoiceNote:
            contentType = .voiceNote
        default:
            contentType = .other
        }
        
        let isOutgoing = message.isOutgoing
        let date = Date(timeIntervalSince1970: TimeInterval(message.date))
        let senderName = "" // Additional fetch would be needed to get the sender's actual name
        
        return MessageItem(
            id: message.id,
            text: text,
            isOutgoing: isOutgoing,
            date: date,
            senderName: senderName,
            contentType: contentType
        )
    }
}
