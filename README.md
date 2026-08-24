# TGWatch ⌚💬

**TGWatch** is a native, standalone watchOS Telegram client built in SwiftUI using **TDLib** (via [TDLibKit](https://github.com/Swiftgram/TDLibKit)) and Apple's **App Intents** framework for Russian Siri voice interaction.

No iPhone companion app is required.

---

## Features

- ⌚ **Standalone watchOS App**: Runs directly on Apple Watch (Optimized for Apple Watch Ultra 2 / Series 4+ on watchOS 10+).
- 🔐 **Dual Auth Flow**:
  - **QR Code login** (recommended): Renders high-contrast QR code on watch screen (via [QRCode](https://github.com/dagronf/QRCode)).
  - **Phone + SMS/Telegram Code + 2FA Cloud Password**.
- 💬 **Messaging**:
  - Conversation list with avatar initials & unread counters.
  - Chat history with outgoing/incoming message bubbles.
  - Dictation and scribble message composer.
- 🗣️ **Siri Voice Integration (Russian)**:
  - *"Напиши [имя] в TGWatch"*
  - *"Отправь сообщение [имя] в TGWatch"*
  - Contact matching via cached entity queries.
- ⚡ **Auto-refresh**: Background periodic polling while active (works without APNs on free developer accounts).

---

## Quick Setup

See [SETUP.md](SETUP.md) for full step-by-step instructions on setting up Xcode, configuring Telegram API credentials, and deploying to Apple Watch with a free Apple Developer account.

---

## Tech Stack

- **Platform**: watchOS 10.0+ (SwiftUI, Swift Concurrency)
- **Telegram Core**: [TDLibKit](https://github.com/Swiftgram/TDLibKit)
- **QR Generation**: [dagronf/QRCode](https://github.com/dagronf/QRCode)
- **Siri**: Apple App Intents Framework
