# All Supported Scenarios

This page lists all functional scenarios currently supported by TelegramReporter.

## 1. First launch report is sent once per account

Trigger:

```swift
await TelegramReporter.startLogReport(token: ..., chatID: ..., additional: ...)
```

Behavior:

- Resolves account-scoped install identity from synchronizable keychain.
- Sends `✅ First Launch` only when launch is first for that account.
- Skips sending on subsequent launches for the same account.

## 2. Force first launch report

Trigger:

```swift
await TelegramReporter.startLogReport(
    token: ..., chatID: ..., additional: ..., ignoreFirstLaunch: true
)
```

Behavior:

- Bypasses account-first check.
- Always sends `✅ First Launch`.

## 3. App active event

Trigger (internal/custom integrations):

- Event type: `.appDidBecomeActive`

Behavior:

- Sends `▶️ App Became Active` with full metadata block.

## 4. Custom event without details

Trigger:

```swift
await TelegramReporter.sendCustomEvent(
    token: ..., chatID: ..., title: "Ping", additional: ...
)
```

Behavior:

- Sends `🧩 <title>`.
- Does not include `📋 Details` block when no details are provided.

## 5. Custom event with details

Trigger:

```swift
await TelegramReporter.sendCustomEvent(
    token: ...,
    chatID: ...,
    title: "Sync Failed",
    details: ["reason": "timeout", "retry": "true"],
    additional: ...
)
```

Behavior:

- Details are sorted by key.
- Multiline values are normalized to single-line text.
- Includes `📋 Details:` section in message body.

## 6. Custom event with optional image

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

- If image is valid, sends one `sendPhoto` request with caption text.
- If image is missing/invalid, falls back to text-only `sendMessage`.

## 7. Feedback without image

Trigger:

```swift
try await TelegramReporter.sendFeedback(
    token: ..., chatID: ..., additional: ..., text: "User feedback"
)
```

Behavior:

- Sends `📝 Feedback` with same metadata layout as first-launch event.
- Adds `💬 User text: ...` line.
- Uses `sendMessage`.

## 8. Feedback with image from URL/file

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

- Supported formats: `png`, `heic`, `jpg`, `jpeg`.
- Sends one Telegram message via `sendPhoto` + caption.

## 9. Feedback with image from iOS picker object

Trigger:

```swift
let pickerImage = FeedbackImage(data: data, fileName: "picker.heic", mimeType: "image/heic")

try await TelegramReporter.sendFeedback(
    token: ...,
    chatID: ...,
    additional: ...,
    text: "From picker",
    feedbackImage: pickerImage
)
```

Behavior:

- Uses picker image directly.
- Sends one `sendPhoto` request with text as caption.

## 10. Feedback rejects empty text

Trigger:

- `text` is empty or whitespace-only.

Behavior:

- Throws `TelegramReporter.FeedbackError.emptyMessage`.
- No network request is sent.

## 11. Unsupported attachment format

Trigger:

- Attachment extension/mime is outside supported image list.

Behavior:

- Attachment is ignored.
- Event is still sent as text-only message.

## 12. Attachment read failure

Trigger:

- Image file URL is provided but cannot be read.

Behavior:

- Logs error.
- Continues by sending message without image.

## 13. Telegram API non-2xx response

Trigger:

- API returns non-success status code.

Behavior:

- Internal transport throws server error.
- Public API swallows error and logs it (no crash).

## 14. Non-HTTP transport response

Trigger:

- URLSession returns non-HTTP response.

Behavior:

- Internal transport throws invalid-response error.
- Public API logs and swallows in reporter entrypoints.

## 15. Hashtag generation

Behavior:

- Every message appends hashtag based on app name: `#<normalizedappname>`.
- Non-alphanumeric symbols are removed.

