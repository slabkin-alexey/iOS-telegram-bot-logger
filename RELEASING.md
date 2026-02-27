# Releasing TelegramReporter

Swift Package Manager uses git tags as versions.

## Release `1.0.1`

Run from repository root:

```bash
git add -A
git commit -m "release: 1.0.1"
git tag -a 1.0.1 -m "Release 1.0.1"
git push origin main
git push origin 1.0.1
```

## Verify tag

```bash
git tag --list | rg "^1\\.0\\.1$"
```

## Consumer setup

In client projects:

```swift
.package(
    url: "https://github.com/<your-org>/<your-repo>.git",
    from: "1.0.1"
)
```

or pin exact:

```swift
.package(
    url: "https://github.com/<your-org>/<your-repo>.git",
    exact: "1.0.1"
)
```
