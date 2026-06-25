# Architecture

Dav Code follows **Clean Architecture** at the feature level and
**MVVM-ish** layering inside each feature, implemented with Riverpod
(`StateNotifierProvider` — no code generation):

```
features/<name>/
├── domain/          entities + repository interfaces — pure Dart, no Flutter import
├── data/            repository implementations, services, runners
└── presentation/    providers (ViewModel-equivalent), screens, widgets
```

`core/` holds everything cross-cutting: theme, constants, shared services
(`FileIOService`, `StorageService`, `SecureStorageService`), the router,
and a handful of app-wide Riverpod providers.

Dependency direction is always **presentation → domain ← data**; domain
never imports Flutter or any data-layer class, which is what makes
business logic (e.g. `CodeFoldingService`, `BracketMatcherService`,
`AutoIndentService`) trivially unit-testable without a widget tree.

## Editor

The whole "professional code editor" feature set is centralized in one
class: `CodeEditorController` (`features/editor/presentation/controllers`),
a `TextEditingController` subclass that:

- Overrides `buildTextSpan()` to render syntax-highlighted text "for
  free" inside a normal `TextField` (via `SyntaxHighlighterService`,
  which wraps `package:highlight`).
- Overrides the `value` setter to detect a single-newline insertion and
  apply `AutoIndentService`'s computed indentation before the change is
  committed.
- Tracks `matchingBracketOffset` (via `BracketMatcherService`) and
  `errorLines` (via `ErrorHighlightService`) so the UI gutter can render
  them.
- Owns code-folding bookkeeping (`CodeFoldingService` computes foldable
  brace/bracket regions; the controller tracks which start-lines are
  currently folded).

**Folding implementation note:** folding is computed at the line level
(brace/bracket nesting), which is the right scope for a mobile scaffold.
Production editors (VS Code, IntelliJ) use a rope/piece-table text buffer
with incremental re-parsing; if you outgrow the line-based approach,
swap `CodeFoldingService` + the `LineNumberGutter` rendering for a
dedicated text-buffer package (e.g. building on `re_editor`) without
touching the rest of the editor feature.

**Bracket-match rendering extension point:** `matchingBracketOffset` is
already computed and exposed as a `ValueNotifier<int?>` on the
controller — there's no visual highlight box wired up yet. To add one:
build a throwaway `TextPainter` with the same text/style/constraints as
the `TextField` in `CodeEditorWidget`, call `getOffsetForCaret`/
`getBoxesForSelection` for the two offsets, and overlay two small
`Positioned` containers in the `Stack` that already wraps the editor.

**Error highlighting note:** `ErrorHighlightService` is a cheap,
language-agnostic linter (unbalanced brackets, unterminated strings) —
not a real analyzer. For real diagnostics, run `dart analyze` (or the
language's equivalent) through the terminal/runner system and feed the
resulting line numbers into the same `Set<int>` the gutter already
reads.

## File Manager

`FileRepositoryImpl` and `EditorRepositoryImpl` both delegate to one
shared `core/services/file_io_service.dart` — raw `dart:io` calls live
in exactly one place. `PermissionService` centralizes the Android
12-vs-13+ storage permission branching. `WorkspaceService` persists
recent projects via Hive (`StorageService`).

The file tree (`FileExplorerScreen`) lazy-loads each directory's
children via a `FutureProvider.family<List<FileNode>, String>` keyed by
path — a folder's contents are only read from disk once the user expands
it, which is the "Lazy loading file" performance requirement.

## Terminal & Code Runner

`Runner` (abstract) → `ProcessRunnerBase` (shared `Process.start` +
line-streaming logic) → four concrete runners: `ShellRunner`,
`DartRunner`, `PythonRunner`, `JavaScriptRunner`, all registered in
`RunnerRegistry`. Adding a new language is: subclass `ProcessRunnerBase`
(or `Runner` directly for something exotic), register it — nothing else
changes.

**Honest limitation:** `DartRunner`/`PythonRunner`/`JavaScriptRunner`
invoke `dart`, `python3`, `node` via `Process.start`. These binaries are
**not present on a stock Android device** — there's no bundled Dart SDK,
CPython, or Node.js. `ShellRunner` works against `/system/bin/sh`, which
*is* present, so raw shell commands work today. When an interpreter
isn't found, `ProcessRunnerBase` catches the `ProcessException` and
surfaces a clear message instead of crashing.

To get real on-device Dart/Python/JS execution, pick one:

1. **Termux integration** — shell out to Termux's installed interpreters
   if the user has Termux installed (check via package manager intents,
   or document it as a prerequisite).
2. **Bundle static/portable interpreter binaries** for each supported
   Android ABI inside the APK (large APK size trade-off) and point each
   Runner's `buildInvocation` at the bundled binary's absolute path
   instead of a bare command name.
3. **In-process interpreters** where available (e.g. Chaquopy for
   Python via a platform channel) instead of `Process.start` — more
   integration work, but no external binary dependency.

None of this requires touching the `Runner` interface — only
`buildInvocation()` in each concrete runner changes.

## Git

`GitRepositoryImpl` shells out to the system `git` binary (same
trade-off as the code runners above — works on desktop/CI, and on
Android devices where `git` is reachable, e.g. via Termux). Every method
maps to one or two `git` CLI invocations, parsed from
`--porcelain`/`--pretty=format:` output for predictable parsing.

Credentials for HTTPS push/pull are stored via `SecureStorageService`
and only ever injected into the remote URL **temporarily** (via
`git remote set-url`) for the duration of the push/pull call, then
restored — they're never written into `.git/config`.

**Fully self-contained alternative:** for a git client with zero
external binary dependency, swap `GitRepositoryImpl` for an
implementation backed by `libgit2` Dart/FFI bindings. The `GitRepository`
interface in `domain/repositories` doesn't change — only the
implementation does.

## AI Assistant

`AiProvider` (domain interface) → `OpenAiCompatibleProvider` (data) is
the single implementation backing **all three** "providers" the spec
asks for (OpenAI / local model / custom endpoint), because they all speak
the same OpenAI Chat Completions wire format. `AiProviderFactory` decides
which `baseUrl`/key to use based on the user's `AiModelConfig`.
`AiAssistantService` turns each high-level action (explain / generate /
find bugs / refactor / autocomplete) into a purpose-built prompt sent
through `AiProvider.chat()`.

## Responsive shell

`HomeScreen` picks between `_DesktopLayout` (Explorer-or-Git rail | Editor
+ docked Terminal | AI Assistant, via `Responsive.isDesktop`) and
`_MobileLayout` (bottom nav for Editor/Terminal/Git/AI + a Drawer holding
the file explorer + a context-sensitive FAB that runs the active file).
Because each tab/pane embeds its own `Scaffold`+`AppBar`, opening the
mobile drawer from any tab goes through a shared
`GlobalKey<ScaffoldState>` (`homeScaffoldKeyProvider`) rather than
Flutter's automatic drawer button (which only auto-wires when the
`AppBar` and `Drawer` share one `Scaffold`).
