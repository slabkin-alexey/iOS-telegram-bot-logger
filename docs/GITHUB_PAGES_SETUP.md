# GitHub Pages Setup

This repository publishes its documentation from `/docs` on the `main` branch.

## Published URL

- [https://slabkin-alexey.github.io/iOS-telegram-bot-logger/](https://slabkin-alexey.github.io/iOS-telegram-bot-logger/)

## Required Documentation Files

Keep these files committed:

- `README.md`
- `CHANGELOG.md`
- `docs/index.md`
- `docs/SCENARIOS.md`
- `docs/ARCHITECTURE.md`
- `docs/GITHUB_PAGES_SETUP.md`
- `docs/_config.yml`

## How To Enable Pages In GitHub

1. Open repository `Settings`
2. Open `Pages`
3. Under `Build and deployment`, select `Deploy from a branch`
4. Choose branch `main`
5. Choose folder `/docs`
6. Save

GitHub will rebuild the site after pushes to `main`.

## What The Site Should Explain

The published documentation should make it easy for a new consumer to understand:

- what TelegramReporter does,
- which services it integrates with,
- which platforms it supports,
- how to install release `1.1`,
- how first-launch, custom event, and feedback delivery work,
- how attachments are handled,
- how the internal architecture is organized,
- how to validate a release locally and in Xcode Cloud.

## Recommended Content Structure

- `index.md`
  Product overview, supported services, installation, public API, validation flow
- `SCENARIOS.md`
  End-to-end supported runtime scenarios, fallback rules, failure behavior
- `ARCHITECTURE.md`
  Internal package layout, MVVM mapping, service flow, threading model
- `GITHUB_PAGES_SETUP.md`
  Publishing instructions and maintenance rules

## Release Validation Checklist

After every release push:

1. Open the published Pages URL
2. Confirm the visible release number is `1.1`
3. Verify links between overview, scenarios, architecture, and setup pages
4. Verify installation snippets reference the latest semantic version
5. Verify code blocks render correctly on the published site

## When Documentation Must Be Updated

Update the Pages content whenever any of the following changes:

- public API,
- supported platforms,
- supported services,
- event message format,
- attachment rules,
- architecture,
- testing workflow,
- release workflow.
