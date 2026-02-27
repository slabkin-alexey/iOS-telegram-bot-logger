# GitHub Pages Setup

This repository keeps Pages content in `/docs`.

## 1. Push docs to GitHub

Make sure these files exist on `main`:

- `README.md`
- `docs/index.md`
- `docs/SCENARIOS.md`
- `docs/ARCHITECTURE.md`
- `docs/GITHUB_PAGES_SETUP.md`
- `docs/_config.yml`

## 2. Enable GitHub Pages

In GitHub:

1. Open **Settings** -> **Pages**
2. In **Build and deployment**:
   - **Source**: `Deploy from a branch`
   - **Branch**: `main`
   - **Folder**: `/docs`
3. Save

GitHub will publish the site and provide a URL:

- `https://<username>.github.io/<repo>/`

## 3. Verify content

Open the published URL and confirm:

- Overview of TelegramReporter
- Full supported scenarios list
- MVVM architecture description
- Public API usage examples
- Versioning/release guidance

## 4. Keep docs up to date

Update docs when:

- Public API changes
- Event formats change
- New integrations are added
- Architecture changes (models, viewmodels, services)
