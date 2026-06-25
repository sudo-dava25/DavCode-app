import 'package:flutter/material.dart';
import '../../data/services/auto_indent_service.dart';
import '../../data/services/bracket_matcher_service.dart';
import '../../data/services/code_folding_service.dart';
import '../../data/services/error_highlight_service.dart';
import '../../data/services/search_replace_service.dart';
import '../../data/services/syntax_highlighter_service.dart';

/// The heart of the code editor: a [TextEditingController] subclass that
/// adds syntax highlighting (via [buildTextSpan]), auto-indentation,
/// bracket matching, and code-folding bookkeeping — i.e. everything the
/// "CODE EDITOR" requirements ask for, centralized in one controller so the
/// widget layer stays simple.
class CodeEditorController extends TextEditingController {
  CodeEditorController({
    required this.languageKey,
    String text = '',
    this.tabSize = 4,
    this.useSpaces = true,
  }) : super(text: text) {
    _recomputeFoldableRegions();
  }

  /// e.g. 'dart', 'python', 'javascript' — see SupportedLanguages.
  String languageKey;
  int tabSize;
  bool useSpaces;

  final SyntaxHighlighterService _highlighter = SyntaxHighlighterService.instance;
  final AutoIndentService _autoIndent = AutoIndentService();
  final BracketMatcherService _bracketMatcher = BracketMatcherService();
  final CodeFoldingService _folding = CodeFoldingService();
  final ErrorHighlightService _errorHighlighter = ErrorHighlightService();
  final SearchReplaceService search = SearchReplaceService();

  Set<int> errorLines = {};

  /// Offset of the bracket matching the one under/after the cursor, if any.
  final ValueNotifier<int?> matchingBracketOffset = ValueNotifier(null);

  /// Lines (by start-line index) the user has manually collapsed.
  final Set<int> foldedStartLines = {};
  List<FoldRegion> _foldableRegions = [];
  List<FoldRegion> get foldableRegions => _foldableRegions;

  bool get hasUnsavedChanges => _dirty;
  bool _dirty = false;
  String _lastSavedText = '';

  void markSaved() {
    _lastSavedText = text;
    _dirty = false;
  }

  void _recomputeFoldableRegions() {
    _foldableRegions = _folding.computeFoldableRegions(text);
    errorLines = _errorHighlighter.findErrorLines(text);
  }

  bool isFoldStart(int lineIndex) => _foldableRegions.any((r) => r.startLine == lineIndex);

  void toggleFold(int lineIndex) {
    if (foldedStartLines.contains(lineIndex)) {
      foldedStartLines.remove(lineIndex);
    } else {
      foldedStartLines.add(lineIndex);
    }
    notifyListeners();
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    var adjusted = newValue;

    if (_isSingleNewlineInsertion(oldText, newValue)) {
      adjusted = _applyAutoIndent(newValue);
    }

    super.value = adjusted;

    _dirty = adjusted.text != _lastSavedText;
    _recomputeFoldableRegions();
    _updateBracketMatch(adjusted);
  }

  bool _isSingleNewlineInsertion(String oldText, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.length != oldText.length + 1) return false;
    final cursor = newValue.selection.baseOffset;
    if (cursor < 1 || cursor > newText.length) return false;
    if (newText[cursor - 1] != '\n') return false;
    final withoutInserted = newText.substring(0, cursor - 1) + newText.substring(cursor);
    return withoutInserted == oldText;
  }

  TextEditingValue _applyAutoIndent(TextEditingValue newValue) {
    final cursor = newValue.selection.baseOffset;
    final textBeforeNewline = newValue.text.substring(0, cursor - 1);
    final indent = _autoIndent.indentForNewLine(
      textBeforeNewline,
      tabSize: tabSize,
      useSpaces: useSpaces,
    );
    if (indent.isEmpty) return newValue;

    final newText = newValue.text.substring(0, cursor) + indent + newValue.text.substring(cursor);
    final newCursor = cursor + indent.length;
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  void _updateBracketMatch(TextEditingValue value) {
    if (!value.selection.isValid || !value.selection.isCollapsed) {
      matchingBracketOffset.value = null;
      return;
    }
    matchingBracketOffset.value = _bracketMatcher.findMatch(value.text, value.selection.baseOffset);
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final baseStyle = style ?? const TextStyle();
    return TextSpan(children: _highlighter.highlight(text, languageKey, baseStyle: baseStyle));
  }

  @override
  void dispose() {
    matchingBracketOffset.dispose();
    super.dispose();
  }
}
