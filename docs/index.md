# TelegramReporter Documentation

TelegramReporter is a Swift Package for routing app events and user feedback into Telegram with structured metadata, stable formatting, and semantic-versioned distribution.

Current documented release: `1.1`

## Product Overview

TelegramReporter is designed for teams that need a low-friction operational reporting channel for:

- first-launch visibility,
- internal QA diagnostics,
- custom runtime events,
- support-oriented user feedback,
- optional screenshot or picker-image delivery.

The package focuses on predictable output, lightweight integration, and safe runtime behavior in real applications.

## What The Package Supports

- First-launch reporting with account-scoped install identity checks
- Lifecycle-style event delivery
- Custom event delivery with sorted metadata details
- Feedback delivery with optional attachment support
- Single Telegram message delivery for image plus text
- Background execution for expensive file and keychain work
- Internal logging for operational traceability

## Integrated Services

- Telegram Bot API
- Apple Keychain
- Swift Package Manager
- Xcode
- Xcode Cloud
- GitHub Pages

## Quick Links

- [All supported scenarios](./SCENARIOS.md)
- [Architecture](./ARCHITECTURE.md)
- [GitHub Pages setup](./GITHUB_PAGES_SETUP.md)

## Installation

```swift
.package(
    url: "https://github.com/slabkin-alexey/iOS-telegram-bot-logger.git",
    from: "1.1"
)
```

## Public API Examples

### First-launch report

```swift
await TelegramReporter.startLogReport(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag
)
```

### Custom event

```swift
await TelegramReporter.sendCustomEvent(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    title: "Sync Failed",
    details: [
        "reason": "timeout",
        "screen": "paywall"
    ],
    additional: TelegramBotConfig.appTag
)
```

### Feedback with an optional file attachment

```swift
try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed,
    imageURL: selectedFeedbackImageFileURL
)
```

### Feedback with an iOS picker image

```swift
let pickerImage = FeedbackImage(
    data: data,
    fileName: "feedback.heic",
    mimeType: "image/heic"
)

try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed,
    feedbackImage: pickerImage
)
```

## Message Baseline

Every report includes:

- `📱 App`
- `📦 Version`
- `🚚 Source`
- `📲 Device`
- `🧠 OS`
- `🌍 Locale`
- `🗺️ Region`

Feedback appends:

- `💬 User text: <message>`

## Validation Workflow

Recommended release validation:

```bash
swift build
swift test
xcodebuild test \
  -project TelegramReporter.xcodeproj \
  -scheme TelegramReporterDemo \
  -testPlan TelegramReporter \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
```

## Published Site

GitHub Pages site:

- [https://slabkin-alexey.github.io/iOS-telegram-bot-logger/](https://slabkin-alexey.github.io/iOS-telegram-bot-logger/)
