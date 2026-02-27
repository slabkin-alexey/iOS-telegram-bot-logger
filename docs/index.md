# TelegramReporter Documentation

TelegramReporter is a Swift Package for sending lifecycle, custom, and feedback events to Telegram with rich runtime metadata.

## Quick Links

- [All Scenarios](./SCENARIOS.md)
- [Architecture (MVVM)](./ARCHITECTURE.md)
- [GitHub Pages Setup](./GITHUB_PAGES_SETUP.md)

## Public API

### Start report (first launch)

```swift
await TelegramReporter.startLogReport(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag
)
```

### Feedback report (optional image)

```swift
try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed,
    imageURL: selectedFeedbackImageFileURL
)
```

### Custom event

```swift
await TelegramReporter.sendCustomEvent(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    title: "Sync Failed",
    details: ["reason": "timeout"],
    additional: TelegramBotConfig.appTag
)
```

## Message Format Baseline

All events include the same metadata block:

- `📱 App`
- `📦 Version`
- `🚚 Source`
- `📲 Device`
- `🧠 OS`
- `🌍 Locale`
- `🗺️ Region`

Feedback additionally appends:

- `💬 User text: <text>`

## Integrations

- Telegram Bot API (`sendMessage`, `sendPhoto`)
- Apple Keychain (synchronizable identity for first-launch behavior)
- Swift Package Manager
- Apple runtime metadata APIs (Bundle, Locale, UIDevice)

## Installation (SPM)

Use semantic version tags:

```swift
.package(
    url: "https://github.com/<your-org>/<your-repo>.git",
    from: "1.0.1"
)
```
