# GitHub Actions: CI/CD Guide

The workflow lives at `.github/workflows/build.yml`. This doc covers
uploading the project, running the workflow, and retrieving the APK —
no GitHub Actions experience required.

## 1. Upload (push) the project to GitHub

```bash
cd dav_code
git init                      # skip if already a git repo
git add .
git commit -m "Initial commit: Dav Code"
git branch -M main
git remote add origin https://github.com/<your-username>/dav_code.git
git push -u origin main
```

Pushing to `main` immediately triggers the workflow — no extra
configuration needed. The workflow file is already committed as part of
this project (`.github/workflows/build.yml`).

## 2. Watch the workflow run

1. Go to your repository on GitHub.
2. Click the **Actions** tab.
3. You'll see a run named **"Build Dav Code APK"** — click it to watch
   live logs for each step (checkout → Flutter setup → analyze → test →
   build → upload).

A green check ✅ means the APK built successfully. A red ✗ means a step
failed — click into the failing step's logs to see why (most commonly
`flutter analyze` or `flutter test` catching an issue).

### Triggering it manually

You don't have to push code to run it:

1. **Actions** tab → **Build Dav Code APK** (left sidebar) → **Run workflow**
   button → pick the branch → **Run workflow**.

This uses the `workflow_dispatch` trigger already configured in
`build.yml`.

## 3. Download the built APK

1. Open the finished workflow run (Actions tab → click the run).
2. Scroll to the **Artifacts** section at the bottom of the run summary
   page.
3. Click **`dav-code-release-apk`** to download a zip containing the
   release APK(s) (split per ABI: `armeabi-v7a`, `arm64-v8a`, `x86_64`).
4. Unzip, then install on a device:
   ```bash
   adb install app-arm64-v8a-release.apk
   ```
   (Most modern phones are `arm64-v8a`.)

Artifacts are retained for 30 days (configurable via `retention-days` in
`build.yml`).

## 4. Creating a GitHub Release for a version

Tag any commit with a version (`vMAJOR.MINOR.PATCH`) and push the tag —
this triggers the **same build job** plus a second `release` job that
attaches the built APKs to an automatically created GitHub Release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

What happens:

1. The `build` job runs exactly as on a normal push, but first rewrites
   `pubspec.yaml`'s version to match the tag (e.g. `1.0.0+<run number>`).
2. The `release` job downloads the produced APKs and publishes a GitHub
   Release named **"Dav Code v1.0.0"** with the APKs attached and
   auto-generated release notes (from commit history since the last tag).

Find it under your repo's **Releases** section (right sidebar on the repo
home page, or `https://github.com/<user>/dav_code/releases`).

See [RELEASE.md](RELEASE.md) for the full release checklist, including
proper app signing before you tag a public release.

## Customizing the workflow

| Want to... | Edit in `build.yml` |
|---|---|
| Build on every branch, not just `main` | Change `branches: [ "main" ]` under `on.push` |
| Fail CI on lint warnings | Remove `--no-fatal-infos` from the `flutter analyze` step |
| Build an App Bundle for Play Store too | Add a step running `flutter build appbundle --release` and upload `build/app/outputs/bundle/release/app-release.aab` |
| Shorten/extend artifact retention | Change `retention-days` |
| Add a Slack/Discord notification on failure | Add a step using `if: failure()` with your webhook action of choice |
