# Dav Code

**Dav Code** is a lightweight mobile IDE built with Flutter — a VS Code /
Android Studio–style code editor, file manager, terminal, Git client, and
AI coding assistant, all in one Android app.

- **Package name:** `com.davcode.dev`
- **Min Android SDK:** 24 (Android 7.0+)
- **Architecture:** Clean Architecture / MVVM, feature-modular
- **State management:** Riverpod (classic `StateNotifierProvider`, no code generation)

---

## ✨ Features

| Module | What's implemented |
|---|---|
| **Code Editor** | Syntax highlighting (12+ languages), line numbers, auto-indent, bracket matching, code folding, search & replace, multiple tabs, word wrap, lightweight error highlighting, custom monospace font |
| **File Manager** | Browse storage, open project, create/rename/delete/copy/move files & folders, recent projects, workspace persistence, Android 12/13+ permission handling |
| **Terminal** | Multi-session terminal, command history, modular Runner system (Shell / Dart / Python / JavaScript), clear/stop |
| **Git** | Init, clone, status, stage, commit, push, pull, branches, commit log, diff |
| **AI Assistant** | Provider-agnostic chat (OpenAI / local model / custom endpoint), explain / generate / find bugs / refactor / autocomplete actions |
| **Settings** | Editor (font size, tab size, word wrap, auto save), Terminal (shell, env vars), AI (API key, provider, model) |
| **CI/CD** | GitHub Actions: analyze → test → build release APK → upload artifact → (on tag) GitHub Release |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how each module is wired together, including the honest limitations (e.g. on-device interpreters/git) and how to extend them.

## 📂 Project structure

```
dav_code/
├── android/                     # Android project (applicationId com.davcode.dev, minSdk 24)
├── .github/workflows/build.yml  # CI/CD: analyze, test, build & release APK
├── docs/                        # Setup, build, architecture & release docs
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/                    # Theme, constants, shared services, DI, router
    └── features/
        ├── editor/              # domain / data / presentation (Clean Architecture)
        ├── file_manager/
        ├── terminal/
        ├── git/
        ├── ai/
        ├── settings/
        └── home/                # Responsive app shell (desktop 3-pane / mobile bottom-nav)
```

Each feature follows the same internal layout:

```
features/<name>/
├── domain/         # Entities + repository interfaces (no Flutter imports)
├── data/           # Repository implementations, services, runners, providers
└── presentation/   # Riverpod providers, screens, widgets
```

## 🚀 Quickstart

```bash
git clone <your-fork-url> dav_code
cd dav_code
flutter pub get
flutter run
```

To build a release APK locally:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

For the full setup guide (Android SDK, permissions, AI keys) see
[docs/SETUP.md](docs/SETUP.md). For CI/CD details see
[docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md) and
[docs/BUILD_APK.md](docs/BUILD_APK.md). For app signing & versioned
releases see [docs/RELEASE.md](docs/RELEASE.md).

## 🛣️ Implementation stages (as delivered)

1. **Stage 1** — Project structure, theme, navigation/routing, responsive shell ✅
2. **Stage 2** — File manager + code editor (syntax highlighting, folding, search) ✅
3. **Stage 3** — Terminal + modular code runner system ✅
4. **Stage 4** — Git integration (status/commit/push/pull/branches) ✅
5. **Stage 5** — AI assistant (provider abstraction, chat, quick actions) ✅

See [docs/ROADMAP.md](docs/ROADMAP.md) for suggested next steps toward a
fully production-grade mobile IDE.

## ⚠️ Known scaffold limitations (read before deep-diving)

This is a complete, working **architecture and feature scaffold** — every
requirement has a real, functioning implementation — but two areas depend
on binaries that aren't bundled with a stock Android app:

- **Code runners (Dart/Python/JavaScript):** they shell out to `dart`,
  `python3`, `node` respectively. These aren't present on a stock Android
  device. The Shell runner works against `/system/bin/sh`. See
  [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#terminal--code-runner) for
  how to bundle real interpreters (Termux integration, static binaries) for
  full on-device execution.
- **Git:** implemented against the system `git` CLI for portability
  (works on desktop/CI and devices with git available, e.g. via Termux).
  For a fully self-contained Android git client, see the libgit2 note in
  the same doc.

Everything else (editor, file manager, settings, AI, UI/UX, CI/CD) runs
exactly as implemented on a real device.

## License

This project was generated as a starting scaffold. Add your own license
of choice (MIT, Apache-2.0, etc.) before publishing.
