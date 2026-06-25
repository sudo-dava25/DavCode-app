# Roadmap: from scaffold to production IDE

Dav Code's current state covers every requirement with a real,
functioning implementation. These are the highest-leverage next steps
toward a polished, production-grade mobile IDE, roughly in priority
order:

## Editor
- [ ] Visual bracket-match highlight overlay (logic already computed —
      see `docs/ARCHITECTURE.md` extension point)
- [ ] Real per-language diagnostics (pipe `dart analyze` / `pylint` /
      `eslint` output through the terminal/runner system into
      `errorLines`)
- [ ] Multi-cursor editing, minimap, find-in-project (across files, not
      just the open tab)
- [ ] Replace line-based folding with a rope/piece-table buffer if you
      need very large file performance + nested fold UX parity with VS Code

## File Manager
- [ ] Drag-and-drop reordering / moving in the tree
- [ ] Show-hidden-files toggle, `.gitignore`-aware filtering
- [ ] Project templates (Flutter/Android/Node starter scaffolds on "New Project")

## Terminal & Runner
- [ ] Bundle real interpreters (or Termux integration) for on-device
      Dart/Python/JS execution — see ARCHITECTURE.md options
- [ ] ANSI color code rendering in terminal output
- [ ] Persist terminal history across app restarts

## Git
- [ ] libgit2/FFI-backed implementation for a zero-dependency git client
- [ ] Per-file diff viewer (side-by-side or unified) using `git diff`'s
      already-fetched output
- [ ] Merge conflict resolution UI
- [ ] SSH key management for SSH remotes (currently HTTPS+token only)

## AI Assistant
- [ ] Streaming responses (switch `AiProvider.chat` to return a `Stream<String>`
      and update `OpenAiCompatibleProvider` to consume SSE)
- [ ] Inline ghost-text autocomplete triggered while typing (the
      `autocomplete()` prompt already exists in `AiAssistantService` —
      wire it to a debounced listener on the active `CodeEditorController`)
- [ ] Context-aware chat (automatically include the active file/selection
      in the system prompt)
- [ ] Per-project AI settings (different model/key per workspace)

## Platform / Performance
- [ ] iOS support (the architecture is Flutter-portable; Android-specific
      code is isolated to `PermissionService` and the terminal/git binary
      assumptions)
- [ ] Background indexing for project-wide search & symbol lookup
- [ ] App size optimization if bundling interpreter binaries (split APKs
      per ABI already wired into CI)

## CI/CD
- [ ] Automated signing in CI using repo secrets (documented in
      `docs/RELEASE.md`, not enabled by default)
- [ ] Add `flutter build appbundle` for Play Store distribution
- [ ] Golden/widget tests for the editor and file explorer
