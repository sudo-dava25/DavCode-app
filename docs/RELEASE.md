# Release Guide: signing, versioning, and cutting a release

## Version management

App version lives in **`pubspec.yaml`**:

```yaml
version: 1.0.0+1   # <versionName>+<versionCode>
```

- `1.0.0` → Android `versionName` (what users see)
- `1` → Android `versionCode` (must strictly increase for Play Store uploads)

`android/app/build.gradle` reads both automatically via Flutter's
standard `local.properties`/`flutter.versionCode`/`flutter.versionName`
mechanism — you don't need to touch any Gradle file when bumping versions
locally.

When you push a `vX.Y.Z` git tag, the GitHub Actions workflow
automatically rewrites `pubspec.yaml`'s version to `X.Y.Z+<CI run number>`
for that build only (the change isn't committed back) — see
[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md#4-creating-a-github-release-for-a-version).

## App signing

By default (no `android/key.properties` present), release builds fall
back to **debug signing** so `flutter build apk --release` always works
out of the box — this is intentional, so the repo "just builds" with zero
setup, but a debug-signed APK is **not suitable for the Play Store** or
for a production release you want users to trust.

### Generate a real signing key

```bash
keytool -genkey -v -keystore davcode-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias davcode
```

Keep `davcode-release.jks` **outside of version control** (it's already
covered by `.gitignore`).

### Wire it into the build

1. Copy the template:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Fill in the real values:
   ```properties
   storePassword=<your keystore password>
   keyPassword=<your key password>
   keyAlias=davcode
   storeFile=../davcode-release.jks
   ```
3. `android/key.properties` is git-ignored — it never gets committed.
   `android/app/build.gradle` automatically detects it and switches the
   release `signingConfig` from debug to your real key — no further
   changes needed.

### Signing in CI (optional, for fully automated signed releases)

To let GitHub Actions produce a **signed** release APK instead of a
debug-signed one:

1. Base64-encode your keystore: `base64 -i davcode-release.jks | pbcopy`
   (or `| xclip`/just redirect to a file on Linux).
2. In your GitHub repo: **Settings → Secrets and variables → Actions**,
   add secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`,
   `KEY_ALIAS`.
3. Add a step to `.github/workflows/build.yml` **before** the build step:
   ```yaml
   - name: Decode signing key
     run: |
       echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > davcode-release.jks
       cat > android/key.properties <<EOF
       storePassword=${{ secrets.KEYSTORE_PASSWORD }}
       keyPassword=${{ secrets.KEY_PASSWORD }}
       keyAlias=${{ secrets.KEY_ALIAS }}
       storeFile=../davcode-release.jks
       EOF
   ```
   The existing build step will then automatically pick up the real
   signing config — no other changes required.

## Cutting a release: checklist

1. Bump the version in `pubspec.yaml` (or let CI derive it from the tag —
   see above) and update any release notes you want to write manually.
2. Make sure `main` is green (Actions tab — last build passed analyze +
   test + build).
3. Tag and push:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. Watch the **Actions** tab — the `build` job runs, then the `release`
   job publishes a GitHub Release with the APK(s) attached.
5. Sanity-check the release page, download the APK, install on a real
   device, smoke-test the core flows (open project, edit a file, run a
   shell command, AI chat).

## Play Store notes (if you go that route later)

- Build an **App Bundle** instead of an APK: `flutter build appbundle --release`.
- Play Store requires a strictly increasing `versionCode` per upload —
  the CI's `+<run number>` scheme already satisfies this as long as run
  numbers only go up (they do, by GitHub's design).
- You'll need to enroll in Play App Signing and complete the Play
  Console's data-safety/permissions declarations — relevant given this
  app requests broad storage access (`MANAGE_EXTERNAL_STORAGE`) for its
  file manager.
