# Changelog

## 2.0.1

### Fixed

- Replaced force-unwrapped Telegram API URLs with a thrown `invalidURL` transport error, so a malformed bot token can no longer crash the host app.

### Changed

- `ReporterLogger` is compiled out of Release builds and builds its messages lazily, removing console output and string-building overhead in production.

## 2.0

### Added

- Expanded `DeviceModelCatalog` to cover the full range of Apple hardware identifiers from AppleDB: all iPhone, iPad, Mac (MacBook/MacBook Air/MacBook Pro, iMac, Mac mini, Mac Studio, Mac Pro), Apple TV, and iPod touch models, including the latest iPhone, MacBook, and iPad mini releases.

## 1.1.1

### Fixed

- Removed tracked generated artifacts (`.build`, `.swiftpm`, `.DS_Store`) from version control to keep the package repository clean for downstream consumers.
- Published a clean semantic version tag `1.1.1` that points to the artifact-free release state.

## 1.1

### Added

- Semantic-versioned package distribution through release tag `1.1`
- Expanded GitHub Pages documentation for installation, architecture, scenarios, and release flow
- iOS demo app for integration validation and Xcode Cloud execution
- Feedback image support for `png`, `jpg`, `jpeg`, and `heic`
- In-memory feedback-image delivery for iOS picker workflows
- Structured unit-test coverage across package and demo-app flows

### Changed

- Refactored the package into a clearer MVVM-oriented internal architecture
- Split major types into dedicated files to improve maintainability and testability
- Aligned feedback formatting with the first-launch metadata baseline
- Moved expensive install-identity and file-loading work off the main thread
- Improved English and Ukrainian demo copy for a more native reading experience
- Removed UI-test target in favor of a unit-test-focused validation pipeline

### Fixed

- Single-message delivery for feedback with an attachment by using Telegram caption transport
- Safer fallback behavior when attachments are unsupported or unavailable
- Cleaner repository state for package consumers by removing generated artifacts from source control
