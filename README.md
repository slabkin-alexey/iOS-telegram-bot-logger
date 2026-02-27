# TelegramReporter

TelegramReporter is a Swift Package for sending app lifecycle, custom events, and user feedback to Telegram.

## Features

- First-launch reporting (once per iCloud account identity)
- App active event reporting
- Custom event reporting with sorted details
- Feedback reporting with optional image attachment
- Single-message feedback with image (`sendPhoto` + caption)
- Built-in runtime logging
- MVVM-based internal architecture

## Integrations

- Telegram Bot API (`sendMessage`, `sendPhoto`)
- Apple Keychain (including synchronizable keychain entry)
- Swift Package Manager
- iOS/tvOS/macOS app metadata (version, locale, region, device, OS)

## Installation (SPM)

Use semantic version tag instead of branch HEAD.

```swift
.package(
    url: "https://github.com/<your-org>/<your-repo>.git",
    from: "1.0.1"
)
```

## Basic Usage

```swift
await TelegramReporter.startLogReport(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag
)
```

```swift
try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed,
    imageURL: selectedFeedbackImageFileURL
)
```

## Feedback Message Format

Feedback uses the same base metadata block as first-launch reports, plus:

- `💬 User text: <message>`

## Versioning

SPM versions come from git tags.

Target release in this repo: `1.0.1`.

See `/RELEASING.md` for exact release commands.

## GitHub Pages Docs

Project docs for GitHub Pages are in `/docs`:

- `/docs/index.md`
- `/docs/SCENARIOS.md`
- `/docs/ARCHITECTURE.md`
- `/docs/GITHUB_PAGES_SETUP.md`
