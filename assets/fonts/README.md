# Editor font assets

Drop a monospace `.ttf` font here (e.g. [Fira Code](https://github.com/tonsky/FiraCode),
JetBrains Mono, Cascadia Code) and uncomment the `fonts:` block in
`pubspec.yaml` to use it as the editor's font instead of the Google
Fonts–loaded default (`AppTheme.editorFont` in
`lib/core/theme/app_theme.dart`).

This placeholder file exists so this directory is tracked by git even
before you add a real font — without it, a fresh `git clone` would be
missing the `assets/fonts/` directory declared in `pubspec.yaml`, which
would otherwise fail the build.
