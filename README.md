# TelegramReporter

TelegramReporter is a production-oriented Swift Package for sending structured operational events and user feedback to Telegram.

It is built for teams that want a lightweight reporting pipeline without introducing a dedicated backend just to capture support messages, QA events, first-launch traces, or optional screenshot attachments.

Current release: `1.1`

## Why This Package Exists

Many iOS teams need a fast way to receive:

- first-launch signals from real installs,
- internal diagnostic events from QA or TestFlight builds,
- structured support feedback from users,
- optional screenshots or picker images,
- stable metadata that makes each report actionable.

TelegramReporter packages that flow into a small Swift API with deterministic message formatting and a stable release tag.

## Core Features

- One-time `✅ First Launch` reporting per account-scoped install identity
- `▶️ App Became Active` reporting
- Custom event delivery with stable alphabetical detail ordering
- Feedback delivery with the same metadata block used by first-launch reporting
- Optional `png`, `jpg`, `jpeg`, and `heic` image delivery
- Single-message Telegram delivery for text plus image via `sendPhoto` caption flow
- Background execution for expensive work such as keychain access and file loading
- Internal console logging for operational traceability
- Swift Package Manager distribution through semantic version tags

## Supported Integrations

- Telegram Bot API
- Apple Keychain
- Swift Package Manager
- Xcode
- Xcode Cloud
- GitHub Pages

## Platform Requirements

- iOS 18+
- tvOS 18+
- macOS 15+
- Swift 6

## Installation

Add the package in Xcode or declare it in `Package.swift`.

Recommended semantic-version integration:

```swift
.package(
    url: "https://github.com/slabkin-alexey/iOS-telegram-bot-logger.git",
    from: "1.1"
)
```

If you need to pin the package exactly:

```swift
.package(
    url: "https://github.com/slabkin-alexey/iOS-telegram-bot-logger.git",
    exact: "1.1"
)
```

Then add the product:

```swift
.product(name: "TelegramReporter", package: "iOS-telegram-bot-logger")
```

## Public API

### First-launch reporting

```swift
await TelegramReporter.startLogReport(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag
)
```

Use this when the app starts and you want a one-time install report per account identity.

### Forced first-launch reporting

```swift
await TelegramReporter.startLogReport(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    ignoreFirstLaunch: true
)
```

Use this when you explicitly want to bypass the one-time gate.

### Custom event reporting

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

### Custom event with an attachment

```swift
await TelegramReporter.sendCustomEvent(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    title: "Debug Snapshot",
    details: [
        "screen": "paywall"
    ],
    additional: TelegramBotConfig.appTag,
    imageFileURL: imageURL
)
```

### Feedback reporting

```swift
try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed
)
```

### Feedback with an iOS picker image

```swift
let pickerImage = FeedbackImage(
    data: imageData,
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

### Feedback with a file URL

```swift
try await TelegramReporter.sendFeedback(
    token: TelegramBotConfig.token,
    chatID: TelegramBotConfig.chatID,
    additional: TelegramBotConfig.appTag,
    text: trimmed,
    imageURL: selectedFeedbackImageFileURL
)
```

## Message Structure

All primary reports share the same metadata baseline:

- `📱 App`
- `📦 Version`
- `🚚 Source`
- `📲 Device`
- `🧠 OS`
- `🌍 Locale`
- `🗺️ Region`

Feedback adds:

- `💬 User text: <message>`

Every message also appends a normalized app hashtag.

This keeps the first-launch and feedback payloads aligned, which makes the Telegram thread easier to scan and search.

## Attachment Rules

Supported attachment formats:

- `png`
- `jpg`
- `jpeg`
- `heic`

Behavior:

- If a supported image is present, TelegramReporter sends one `sendPhoto` request with the formatted text as the caption.
- If the file cannot be loaded or the format is unsupported, reporting falls back to text-only delivery instead of dropping the event.
- Picker-provided images can be sent directly through `FeedbackImage` without a temporary file dependency.

## Architecture

TelegramReporter `1.1` uses a lightweight MVVM-oriented internal structure:

- `Public`
- `Models`
- `ViewModels`
- `Services`
- `Infrastructure`

Heavy work is intentionally executed off the main thread:

- keychain install-identity lookup,
- file-based image loading,
- attachment preparation.

This keeps integration safe for UI-driven apps and avoids unnecessary main-thread stalls.

## Testing

The repository includes:

- Swift Package Manager unit tests,
- an iOS demo app,
- demo app unit tests,
- a shared Xcode test plan for local CI and Xcode Cloud.

Recommended verification commands:

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

## Documentation

- [GitHub Pages overview](./docs/index.md)
- [Supported scenarios](./docs/SCENARIOS.md)
- [Architecture](./docs/ARCHITECTURE.md)
- [GitHub Pages setup](./docs/GITHUB_PAGES_SETUP.md)

Published Pages URL:

- [https://slabkin-alexey.github.io/iOS-telegram-bot-logger/](https://slabkin-alexey.github.io/iOS-telegram-bot-logger/)

## Releasing

TelegramReporter is versioned by git tag.

Release documentation:

- [`/RELEASING.md`](./RELEASING.md)
- [`/CHANGELOG.md`](./CHANGELOG.md)
