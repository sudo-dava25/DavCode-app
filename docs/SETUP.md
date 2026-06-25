# Setup Guide

## 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, ≥ 3.19)
- Android SDK + a connected device or emulator (Android 7.0 / API 24+)
- Java 17 (bundled with most recent Android Studio installs)
- Git

Check your environment:

```bash
flutter doctor -v
```

Resolve anything flagged ✗ before continuing (most commonly: Android
licenses — run `flutter doctor --android-licenses`).

## 2. Get the code

```bash
git clone <your-fork-url> dav_code
cd dav_code
flutter pub get
```

No code generation step is required (the project intentionally avoids
`build_runner`/codegen to keep `flutter pub get` + `flutter run` enough to
get going).

## 3. Run on a device/emulator

```bash
flutter devices        # confirm your target is listed
flutter run             # debug build, hot reload enabled
```

## 4. Android permissions

On first launch, opening a project folder will prompt for storage access:

- **Android 7–12:** classic `READ/WRITE_EXTERNAL_STORAGE` runtime permission.
- **Android 13+:** `MANAGE_EXTERNAL_STORAGE` ("All files access"), requested
  via `PermissionService` (`lib/features/file_manager/data/services/permission_service.dart`).
  If the system dialog doesn't appear (some OEM ROMs), the app falls back
  to opening the app's permission settings screen directly.

## 5. Configure the AI assistant (optional)

Dav Code ships with a provider-agnostic AI layer. To use it:

1. Open the app → **Settings → AI Assistant**.
2. Pick a provider:
   - **OpenAI** — paste your API key (starts with `sk-...`). Get one at
     <https://platform.openai.com/api-keys>.
   - **Local Model** — point it at an OpenAI-compatible local server (e.g.
     [Ollama](https://ollama.com) running `ollama serve`, which exposes an
     OpenAI-compatible endpoint at `http://127.0.0.1:11434/v1`). Note: "local"
     from the Android app's perspective usually means a server reachable on
     your LAN, not literally on-device — see docs/ARCHITECTURE.md.
   - **Custom Endpoint** — any OpenAI-compatible Chat Completions API
     (self-hosted vLLM, LM Studio, Azure OpenAI gateway, etc).
3. The API key is stored encrypted on-device (Android Keystore via
   `flutter_secure_storage`) — never written to disk in plain text, never
   committed to the repo.

## 6. Configure Git (optional)

Git push/pull need a `git` binary reachable on the runtime `PATH`. On a
stock Android device this typically isn't present — install it via
[Termux](https://termux.dev) (`pkg install git`) and ensure Dav Code's
process can resolve `git` on `PATH` (see docs/ARCHITECTURE.md for details
and the libgit2 alternative for a fully self-contained client).

For HTTPS push/pull with a personal access token, use the Git screen's
credential flow (stores `username`/token via `SecureStorageService`,
never written into `.git/config`).

## 7. Editor preferences

**Settings → Editor**: font size, tab size, word wrap, auto save.
Defaults: 14pt monospace font, 4-space tabs, word wrap on, auto save on.

## Next steps

- [docs/BUILD_APK.md](BUILD_APK.md) — building a release APK, locally or via CI
- [docs/GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) — how the included CI pipeline works
- [docs/RELEASE.md](RELEASE.md) — signing & cutting versioned releases
- [docs/ARCHITECTURE.md](ARCHITECTURE.md) — module-by-module design notes
