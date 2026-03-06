# Architecture

TelegramReporter `1.1` uses a lightweight MVVM-oriented internal architecture with explicit separation between public API, domain models, message composition, orchestration, and low-level infrastructure.

The package does not render UI. In this design, the "view" is the final Telegram-ready message text plus the optional attachment payload.

## Source Layout

- `Sources/TelegramReporter/Public`
  Public facade and public error contracts
- `Sources/TelegramReporter/Models`
  Core package models and transport-facing payload types
- `Sources/TelegramReporter/ViewModels`
  Message composition and attachment projection
- `Sources/TelegramReporter/Services`
  Application-level orchestration and transport entry points
- `Sources/TelegramReporter/Infrastructure`
  Logging, device metadata, keychain persistence, and background execution

## MVVM Mapping

### Model

Core package data structures:

- `Config`
- `TelegramReporterEvent`
- `FeedbackImage`
- `TransportAttachment`
- `TransportSendMessagePayload`
- `TelegramTransportError`

### ViewModel

Types that transform domain input into Telegram-ready output:

- `MessageBuilder`
  Builds the final text payload, formats metadata, sorts details, and normalizes values
- `ReportViewModel`
  Derives the optional attachment for a given event, including in-memory feedback images

### Services

Application-facing orchestration:

- `ReporterService`
  Drives event-to-message delivery
- `Transport`
  Sends `sendMessage` and `sendPhoto` requests
- `FeedbackImageLoader`
  Validates supported image inputs and loads file data
- `InstallIdentityService`
  Decides whether the one-time first-launch event should be sent

### Infrastructure

Low-level concerns:

- `ReporterLogger`
  Console logging for runtime traceability
- `DeviceModelResolver`
  Converts device identifiers into readable model names
- `AccountInstallIdentity`
  Account-scoped install identity strategy
- `KeychainStore`
  Low-level persistence wrapper
- `KeychainSecurityClient`
  Security framework adapter
- `BackgroundTaskRunner`
  Off-main execution helper for expensive operations

## Execution Flow

1. The client app calls a `TelegramReporter` public API method.
2. Input is validated and normalized.
3. Expensive identity or file work is scheduled off the main thread.
4. `MessageBuilder` creates the final Telegram text.
5. `ReportViewModel` derives the optional attachment.
6. `ReporterService` selects the delivery path.
7. `Transport` sends either JSON or multipart data to Telegram.
8. `ReporterLogger` records the path and result.

## Performance Strategy

Performance-sensitive work is kept off the main thread:

- install-identity lookup,
- keychain access,
- file-based image loading,
- attachment preparation.

This keeps the package safe for SwiftUI or UIKit flows that trigger reporting from user actions.

## Refactor Safety Goals

The `1.1` refactor keeps the following guarantees:

- no intentional business-logic changes,
- stable public API,
- deterministic message formatting,
- graceful fallback behavior,
- improved testability,
- one primary type per file in package sources.
