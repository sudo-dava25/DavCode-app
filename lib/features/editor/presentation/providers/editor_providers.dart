import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../data/repositories/editor_repository_impl.dart';
import '../../domain/repositories/editor_repository.dart';
import '../controllers/code_editor_controller.dart';
import '../../domain/entities/editor_tab.dart';

final editorRepositoryProvider = Provider<EditorRepository>((ref) => EditorRepositoryImpl());

/// Drives the "Multiple file tabs" feature: open tabs, the active tab, and
/// per-tab CodeEditorControllers (which is where syntax highlighting,
/// auto-indent, folding, and bracket matching all live).
class EditorTabsNotifier extends StateNotifier<List<EditorTab>> {
  EditorTabsNotifier(this._repository) : super([]);

  final EditorRepository _repository;
  final Map<String, CodeEditorController> controllers = {};
  String? activeTabId;
  final _uuid = const Uuid();

  CodeEditorController? get activeController =>
      activeTabId == null ? null : controllers[activeTabId];

  EditorTab? get activeTab => state.firstWhereOrNull((t) => t.id == activeTabId);

  Future<void> openFile(String path) async {
    // If already open, just focus it.
    final existing = state.firstWhereOrNull((t) => t.filePath == path);
    if (existing != null) {
      activeTabId = existing.id;
      state = [...state];
      return;
    }

    final language = SupportedLanguages.fromFileName(path);
    final size = await _repository.fileSize(path);
    final isLarge = size > AppConstants.largeFileThresholdBytes;
    final content = isLarge
        ? await _repository.readFilePreview(path)
        : await _repository.readFile(path);

    final id = _uuid.v4();
    final tab = EditorTab(
      id: id,
      filePath: path,
      fileName: path.split('/').last,
      language: language,
      content: content,
      isReadOnlyLargeFile: isLarge,
    );

    controllers[id] = CodeEditorController(
      languageKey: language.highlightModeKey,
      text: content,
    )..markSaved();

    state = [...state, tab];
    activeTabId = id;
  }

  void focusTab(String tabId) {
    activeTabId = tabId;
    state = [...state];
  }

  Future<void> closeTab(String tabId) async {
    controllers[tabId]?.dispose();
    controllers.remove(tabId);
    state = state.where((t) => t.id != tabId).toList();
    if (activeTabId == tabId) {
      activeTabId = state.isNotEmpty ? state.last.id : null;
    }
  }

  Future<void> saveActiveTab() async {
    final tab = activeTab;
    final controller = activeController;
    if (tab == null || controller == null) return;
    await _repository.writeFile(tab.filePath, controller.text);
    controller.markSaved();
    state = [
      for (final t in state)
        if (t.id == tab.id) t.copyWith(content: controller.text, isDirty: false) else t,
    ];
  }

  void markActiveTabDirty() {
    final tab = activeTab;
    if (tab == null) return;
    state = [
      for (final t in state)
        if (t.id == tab.id) t.copyWith(isDirty: true) else t,
    ];
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

final editorTabsProvider = StateNotifierProvider<EditorTabsNotifier, List<EditorTab>>((ref) {
  return EditorTabsNotifier(ref.watch(editorRepositoryProvider));
});

/// Editor display settings (font size, word wrap, tab size) — persisted via
/// StorageService elsewhere (features/settings owns persistence; this
/// provider just exposes the live in-memory values to the editor screen).
class EditorSettings {
  final double fontSize;
  final bool wordWrap;
  final int tabSize;
  final bool useSpaces;

  const EditorSettings({
    this.fontSize = AppConstants.defaultFontSize,
    this.wordWrap = true,
    this.tabSize = AppConstants.defaultTabSize,
    this.useSpaces = true,
  });

  EditorSettings copyWith({double? fontSize, bool? wordWrap, int? tabSize, bool? useSpaces}) {
    return EditorSettings(
      fontSize: fontSize ?? this.fontSize,
      wordWrap: wordWrap ?? this.wordWrap,
      tabSize: tabSize ?? this.tabSize,
      useSpaces: useSpaces ?? this.useSpaces,
    );
  }
}

class EditorSettingsNotifier extends StateNotifier<EditorSettings> {
  EditorSettingsNotifier() : super(const EditorSettings());

  void setFontSize(double size) => state = state.copyWith(fontSize: size);
  void toggleWordWrap() => state = state.copyWith(wordWrap: !state.wordWrap);
  void setTabSize(int size) => state = state.copyWith(tabSize: size);
}

final editorSettingsProvider = StateNotifierProvider<EditorSettingsNotifier, EditorSettings>(
  (ref) => EditorSettingsNotifier(),
);
