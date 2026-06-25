import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/code_editor_controller.dart';
import '../providers/editor_providers.dart';
import 'line_number_gutter.dart';

/// The actual text-editing surface: line numbers + highlighted, editable
/// text, with a lightweight overlay that highlights matching brackets.
///
/// Implementation notes:
/// - Syntax highlighting comes from [CodeEditorController.buildTextSpan],
///   so the TextField renders colored text "for free".
/// - Vertical scrolling is shared between the gutter and the text via one
///   SingleChildScrollView; horizontal scrolling (when word-wrap is off)
///   is local to the text area only, so line numbers stay fixed.
/// - Bracket-match highlighting is drawn as a small overlay box computed
///   from a throwaway TextPainter using the same text/style/constraints.
class CodeEditorWidget extends StatefulWidget {
  final CodeEditorController controller;
  final EditorSettings settings;
  final bool readOnly;
  final VoidCallback? onChanged;

  const CodeEditorWidget({
    super.key,
    required this.controller,
    required this.settings,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  TextStyle get _style => AppTheme.editorFont(fontSize: widget.settings.fontSize);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final lineCount = value.text.isEmpty ? 1 : value.text.split('\n').length;

        final textField = TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: widget.readOnly,
          maxLines: null,
          minLines: null,
          expands: false,
          cursorColor: AppColors.accent,
          style: _style,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            filled: false,
          ),
          onChanged: (_) => widget.onChanged?.call(),
        );

        return Container(
          color: AppColors.bg,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _verticalScroll,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LineNumberGutter(
                        lineCount: lineCount,
                        fontSize: widget.settings.fontSize,
                        foldableRegions: widget.controller.foldableRegions,
                        foldedStartLines: widget.controller.foldedStartLines,
                        errorLines: widget.controller.errorLines,
                        onToggleFold: (line) {
                          setState(() => widget.controller.toggleFold(line));
                        },
                      ),
                      const VerticalDivider(width: 1, color: AppColors.border),
                      Expanded(
                        child: widget.settings.wordWrap
                            ? Padding(padding: const EdgeInsets.only(top: 2), child: textField)
                            : SingleChildScrollView(
                                controller: _horizontalScroll,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 2400, // generous virtual width for non-wrapped lines
                                  child: Padding(padding: const EdgeInsets.only(top: 2), child: textField),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
