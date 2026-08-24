# TGWatch — Setup Instructions

## Prerequisites

- **Mac** with **Xcode 15.0+** installed
- **Apple Watch Ultra 2** (or any Apple Watch running watchOS 10+) paired to your iPhone
- **Apple Developer Account** (free Personal Team is fine)
- **Telegram API credentials** from [my.telegram.org](https://my.telegram.org)

---

## Step 1: Get Telegram API Credentials

1. Open [my.telegram.org](https://my.telegram.org) in a browser
2. Log in with your phone number
3. Enter the confirmation code sent to your Telegram app
4. Click **"API development tools"**
5. Fill out the form:
   - **App title**: `TGWatch`
   - **Short name**: `tgwatch`
   - **Platform**: Other
6. Save your `api_id` (number) and `api_hash` (string) — you'll need these later

---

## Step 2: Create the Xcode Project

1. Open Xcode → **File → New → Project**
2. Select the **watchOS** tab → choose **App** template → Next
3. Configure:
   - **Product Name**: `TGWatch`
   - **Team**: Select your Personal Team
   - **Organization Identifier**: `com.tgwatch`
   - **Bundle Identifier**: will auto-fill as `com.tgwatch.TGWatch`
   - **Interface**: SwiftUI
   - **Watch-only App**: ✅ Yes (checked)
4. Click **Create** and save to any location

---

## Step 3: Add Source Files

1. **Delete** the default `ContentView.swift` and `TGWatchApp.swift` that Xcode created
2. **Drag and drop** the entire `TGWatch/` folder contents from this repo into your Xcode project:
   - `Config/` — TelegramConfig.swift
   - `Services/` — TelegramService.swift, ContactStore.swift
   - `Models/` — ChatItem.swift, MessageItem.swift
   - `Views/` — all view files (Auth, Chat, ChatList, Settings)
   - `Intents/` — all Siri intent files
   - `TGWatchApp.swift` — app entry point
   - `ContentView.swift` — root router
3. When prompted, ensure:
   - ✅ **Copy items if needed** is checked
   - ✅ **Create folder references** or **Create groups** is selected
   - ✅ Target **TGWatch** is checked
4. **Add localizations**: Drag `Localizations/ru.lproj` and `Localizations/en.lproj` into the project

---

## Step 4: Add Swift Package Dependencies

1. In Xcode: **File → Add Package Dependencies...**
2. Add **TDLibKit**:
   - Paste URL: `https://github.com/Swiftgram/TDLibKit`
   - Click **Add Package**
   - Select product **TDLibKit** → Add to target **TGWatch**
   - ⏳ This will download ~300MB of prebuilt binaries — be patient
3. Add **QRCode**:
   - Paste URL: `https://github.com/dagronf/QRCode`
   - Click **Add Package**
   - Select product **QRCode** → Add to target **TGWatch**

---

## Step 5: Configure Capabilities

1. Select your project in the navigator → select the **TGWatch** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** → search and add **Siri**
4. Ensure **Team** is set to your Personal Team
5. Ensure **Deployment Target** is `watchOS 10.0` or later

---

## Step 6: Enter API Credentials

1. Open `Config/TelegramConfig.swift`
2. Replace the placeholder values:
   ```swift
   static let apiId: Int32 = 12345678      // Your api_id from my.telegram.org
   static let apiHash: String = "abcdef..." // Your api_hash from my.telegram.org
   ```

---

## Step 7: Build & Run

1. Connect your Apple Watch (or ensure it's reachable via Wi-Fi)
2. Select your Apple Watch as the run destination in Xcode
3. Press **⌘R** (Build & Run)
4. First build may take several minutes due to TDLib compilation

---

## Step 8: Log In

On the Apple Watch:
1. Tap **"QR-код"** (recommended) or **"Номер телефона"**
2. For QR login:
   - A QR code appears on the watch screen
   - On your phone: open Telegram → Settings → Devices → Link Desktop Device
   - Scan the QR code on the watch
3. For phone login:
   - Enter your phone number (e.g., `+79123456789`)
   - Enter the verification code sent to your Telegram
   - If 2FA is enabled, enter your cloud password

---

## Using Siri

After login, you can use Siri in Russian:

- **"Напиши [имя] в TGWatch"** — sends a message to a contact
- **"Отправь сообщение [имя] в TGWatch"** — same, different phrasing
- **"Напиши сообщение в TGWatch"** — Siri will ask who and what

Example: *"Привет Siri, напиши Маше в TGWatch"* → Siri asks *"Что написать?"* → say your message.

---

## Important Notes

### Free Developer Account Limitations
- ⚠️ **App expires every 7 days** — you must re-deploy from Xcode weekly
- ⚠️ **Max 3 sideloaded apps** on your Apple Watch at once
- ⚠️ **No push notifications** — messages arrive only when the app is open
- ✅ Siri intents work fine on free accounts
- ✅ Direct networking (Wi-Fi/LTE) works fine

### Troubleshooting
- **Build errors with TDLibKit**: Ensure you're using Xcode 15+ and have selected the correct target
- **QR code not scanning**: Make sure the watch screen brightness is at maximum
- **Siri not recognizing commands**: Restart the watch after first install to index App Shortcuts
- **App crashes on launch**: Verify your `api_id` and `api_hash` are correct
