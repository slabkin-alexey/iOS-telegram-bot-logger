# All Supported Scenarios

This page documents the supported runtime behavior of TelegramReporter `1.1.1`.

## 1. First-launch report is sent once per account identity

Trigger:

```swift
await TelegramReporter.startLogReport(
    token: ...,
    chatID: ...,
    additional: ...
)
```

Behavior:

- Resolves a synchronizable account-scoped install identity
- Sends `✅ First Launch` only once for that identity
- Skips later launches for the same account identity

## 2. Forced first-launch report

Trigger:

```swift
await TelegramReporter.startLogReport(
    token: ...,
    chatID: ...,
    additional: ...,
    ignoreFirstLaunch: true
)
```

Behavior:

- Bypasses the one-time first-launch gate
- Always sends the first-launch report

## 3. App active report

Trigger:

- internal event `.appDidBecomeActive`

Behavior:

- Sends `▶️ App Became Active`
- Reuses the same metadata baseline as other report types

## 4. Custom event without details

Trigger:

```swift
await TelegramReporter.sendCustomEvent(
    token: ...,
    chatID: ...,
    title: "Ping",
    additional: ...
)
```

Behavior:

- Sends `🧩 Ping`
- Omits the details section entirely

## 5. Custom event with structured details

Trigger:

```swift
await TelegramReporter.sendCustomEvent(
    token: ...,
    chatID: ...,
    title: "Sync Failed",
    details: [
        "reason": "timeout",
        "retry": "true"
    ],
    additional: ...
)
```

Behavior:

- Sorts keys alphabetically
- Normalizes multi-line values into a single line
- Adds `📋 Details:` only when the dictionary is not empty

## 6. Custom event with an image attachment

Trigger:

```swift
await TelegramReporter.sendCustomEvent(
    token: ...,
    chatID: ...,
    title: "Debug Snapshot",
    details: [:],
    additional: ...,
    imageFileURL: fileURL
)
```

Behavior:

- Accepts supported image formats
- Uses Telegram `sendPhoto`
- Sends image and formatted text as one Telegram message

## 7. Custom event falls back to text-only delivery

Trigger:

- missing image file
- unsupported file extension
- file loading failure

Behavior:

- Does not drop the event
- Falls back to `sendMessage`

## 8. Feedback without image

Trigger:

```swift
try await TelegramReporter.sendFeedback(
    token: ...,
    chatID: ...,
    additional: ...,
    text: "User feedback"
)
```

Behavior:

- Sends `📝 Feedback`
- Reuses the first-launch metadata baseline
- Appends `💬 User text: ...`
- Uses `sendMessage`

## 9. Feedback with an image file URL

Trigger:

```swift
try await TelegramReporter.sendFeedback(
    token: ...,
    chatID: ...,
    additional: ...,
    text: "User feedback",
    imageURL: selectedFeedbackImageFileURL
)
```

Behavior:

- Supports `png`, `jpg`, `jpeg`, and `heic`
- Uses Telegram `sendPhoto`
- Sends the image and text as one message

## 10. Feedback with a picker-provided image

Trigger:

```swift
let pickerImage = FeedbackImage(
    data: data,
    fileName: "feedback.heic",
    mimeType: "image/heic"
)

try await TelegramReporter.sendFeedback(
    token: ...,
    chatID: ...,
    additional: ...,
    text: "User feedback",
    feedbackImage: pickerImage
)
```

Behavior:

- Uses the in-memory image directly
- Avoids extra file loading
- Sends one Telegram message with caption

## 11. Feedback validation

Trigger:

- empty message
- whitespace-only message

Behavior:

- Throws `TelegramReporter.FeedbackError.emptyMessage`
- Sends no network request

## 12. Unsupported image formats are ignored safely

Trigger:

- unsupported extensions such as `gif` or `bmp`

Behavior:

- Logs the issue internally
- Drops only the attachment
- Preserves message delivery

## 13. File loading failure does not crash reporting

Trigger:

- broken file URL
- missing file
- read permission issue

Behavior:

- Logs the failure
- Continues without media

## 14. Server-side Telegram failures are swallowed by public API entry points

Trigger:

- Telegram returns a non-2xx response

Behavior:

- Internal transport throws an error
- Public entry points log the failure and avoid crashing the app

## 15. Invalid non-HTTP responses are handled safely

Trigger:

- URL loading stack returns a non-HTTP response

Behavior:

- Internal transport throws `invalidResponse`
- Public entry points log and swallow the failure

## 16. Stable metadata block

Every message contains:

- `📱 App`
- `📦 Version`
- `🚚 Source`
- `📲 Device`
- `🧠 OS`
- `🌍 Locale`
- `🗺️ Region`

This baseline is shared across:

- first launch
- app active
- custom events
- feedback

## 17. Stable hashtag generation

Every message ends with:

- `#<normalized-app-name>`

Behavior:

- lowercases the app name
- removes non-alphanumeric separators
- falls back to `#unknownapp` when necessary

## 18. Demo app validation coverage

The repository also includes an iOS demo app that supports:

- first-launch flow validation
- custom-event flow validation
- feedback validation
- attachment validation
- English and Ukrainian localization review
- unit-test validation through a shared Xcode test plan
