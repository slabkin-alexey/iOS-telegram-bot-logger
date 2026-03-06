# Releasing TelegramReporter

TelegramReporter is distributed as a Swift Package Manager dependency through annotated git tags.

Release `1.1` is intended to be consumed as a semantic version, not as a floating branch reference.

## Release Checklist

Run from the repository root:

```bash
swift build
swift test
xcodebuild test \
  -project TelegramReporter.xcodeproj \
  -scheme TelegramReporterDemo \
  -testPlan TelegramReporter \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
git add -A
git commit -m "release: 1.1"
git tag -a 1.1 -m "Release 1.1"
git push origin main
git push origin 1.1
```

## Post-Push Validation

Verify the local tag:

```bash
git tag --list | rg "^1\\.1$"
```

Verify the remote tag:

```bash
git ls-remote --tags origin | rg "refs/tags/1\\.1"
```

## Consumer Installation

Recommended:

```swift
.package(
    url: "https://github.com/slabkin-alexey/iOS-telegram-bot-logger.git",
    from: "1.1"
)
```

Exact pin:

```swift
.package(
    url: "https://github.com/slabkin-alexey/iOS-telegram-bot-logger.git",
    exact: "1.1"
)
```

## GitHub Pages Release Validation

After pushing `main`, confirm that GitHub Pages rebuilds from `/docs` and that the published documentation reflects:

- release `1.1`,
- the current installation snippet,
- the current supported scenarios,
- the current architecture layout,
- the current test and validation commands.

Published documentation URL:

- [https://slabkin-alexey.github.io/iOS-telegram-bot-logger/](https://slabkin-alexey.github.io/iOS-telegram-bot-logger/)
