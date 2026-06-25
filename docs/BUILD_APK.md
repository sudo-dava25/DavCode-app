# Building the APK

## Option A — Build locally

```bash
flutter pub get
flutter build apk --release
```

Output: **`build/app/outputs/flutter-apk/app-release.apk`**

Other useful variants:

```bash
# Smaller, per-architecture APKs (recommended for distributing manually)
flutter build apk --release --split-per-abi
# -> app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk

# Debug build (faster, unoptimized, installable side-by-side)
flutter build apk --debug

# App Bundle (required for Play Store uploads)
flutter build appbundle --release
```

Install directly to a connected device:

```bash
flutter install --release
# or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Signing

Out of the box, `android/app/build.gradle` falls back to **debug signing**
for release builds whenever `android/key.properties` is absent — so
`flutter build apk --release` always succeeds with zero extra setup. This
is fine for testing/distributing internally, but **not** for the Play
Store. See [RELEASE.md](RELEASE.md) to set up a real signing key.

## Option B — Build via GitHub Actions (no local Flutter install needed)

Every push to `main` (and every pull request) automatically:

1. Checks out the repo
2. Sets up Flutter (stable channel) + Java 17 + Gradle cache
3. Runs `flutter pub get`
4. Runs `flutter analyze`
5. Runs `flutter test`
6. Builds `flutter build apk --release --split-per-abi`
7. Uploads the resulting APKs as a workflow artifact named
   **`dav-code-release-apk`**

See [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) for how to trigger this and
download the resulting APK without writing any YAML yourself, and
[RELEASE.md](RELEASE.md) for turning a build into a versioned GitHub
Release with the APK attached.

## Troubleshooting

| Problem | Fix |
|---|---|
| `Execution failed for task ':app:processReleaseManifest'` mentioning a missing icon | Re-run `flutter pub get`; confirm `android/app/src/main/res/mipmap-*/ic_launcher.png` exist (they're included in this repo) |
| `Your project's Gradle version (X) is lower than Flutter's minimum supported version (Y)` | Flutter's "stable" channel keeps raising its minimum required Gradle/AGP version over time. Bump `distributionUrl` in `android/gradle/wrapper/gradle-wrapper.properties` to the version Flutter asks for (or newer), and bump the AGP (`com.android.application`) version in `android/settings.gradle` to one that supports that Gradle version — check the [AGP–Gradle compatibility table](https://developer.android.com/build/releases/gradle-plugin#compatibility) |
| `SDK location not found` | Run `flutter doctor`; ensure `ANDROID_HOME`/`ANDROID_SDK_ROOT` is set, or let `flutter` auto-write `android/local.properties` on first build |
| Gradle build very slow on first run | Expected — Gradle downloads its distribution + dependencies once; subsequent builds are cached (also true in CI, via the Gradle cache step) |
| `flutter analyze` reports issues | These are non-fatal in CI (`--no-fatal-infos`) by default; fix at your convenience, or tighten CI by removing that flag |
