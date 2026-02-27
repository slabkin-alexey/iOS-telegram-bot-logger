# Architecture (MVVM)

TelegramReporter is organized as MVVM + service layers without UI coupling.

## Folder Layout

- `Sources/TelegramReporter/Public`
  - Public facade and public error contracts.
- `Sources/TelegramReporter/Models`
  - Domain models, payloads, config, event types, transport data structures.
- `Sources/TelegramReporter/ViewModels`
  - Message composition and event-to-delivery mapping.
- `Sources/TelegramReporter/Services`
  - Reporting orchestration, transport, image preparation, install identity helpers.
- `Sources/TelegramReporter/Infrastructure`
  - Logging, device model resolving, keychain-based install identity.

## MVVM Responsibilities

- Model:
  - `TelegramReporterEvent`, `Config`, `FeedbackImage`, transport payloads/errors.
- ViewModel:
  - `MessageBuilder` and `ReportViewModel` generate final Telegram message text and attachment routing.
- View:
  - Telegram message/caption is the rendered output target.
- Services:
  - `ReporterService` orchestrates sending.
  - `Transport` executes Telegram API requests.
  - `FeedbackImageLoader` normalizes optional image input.

## Flow

1. App calls `TelegramReporter` public API.
2. Input is validated and normalized.
3. Event + metadata are transformed by ViewModel layer.
4. Service layer selects `sendMessage` or `sendPhoto`.
5. Transport sends request and logs result.

## Design Goal

- Keep business behavior unchanged.
- Keep public API stable.
- Keep internals modular for safe future extensions.
