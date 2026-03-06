# Changelog

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
