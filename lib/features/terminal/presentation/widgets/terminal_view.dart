import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/terminal_line.dart';
import '../../domain/entities/terminal_session.dart';

/// Renders one terminal session's scrollable output console + command
/// input ("Output console" / "Command input" requirements).
class TerminalView extends StatefulWidget {
  final TerminalSession session;
  final void Function(String command) onSubmit;

  const TerminalView({super.key, required this.session, required this.onSubmit});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  int _historyIndex = -1;

  @override
  void didUpdateWidget(covariant TerminalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _colorFor(TerminalLineType type) {
    switch (type) {
      case TerminalLineType.input:
        return AppColors.accent;
      case TerminalLineType.stderr:
        return AppColors.error;
      case TerminalLineType.system:
        return AppColors.textMuted;
      case TerminalLineType.stdout:
        return AppColors.terminalText;
    }
  }

  void _submit() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    widget.onSubmit(text);
    _inputController.clear();
    _historyIndex = -1;
  }

  void _historyUp() {
    final history = widget.session.commandHistory;
    if (history.isEmpty) return;
    _historyIndex = (_historyIndex + 1).clamp(0, history.length - 1);
    _inputController.text = history[history.length - 1 - _historyIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.terminalBg,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: widget.session.output.length,
              itemBuilder: (context, index) {
                final line = widget.session.output[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    line.text,
                    style: AppTheme.editorFont(fontSize: 12.5, color: _colorFor(line.type)),
                  ),
                );
              },
            ),
          ),
          if (widget.session.isRunning)
            const LinearProgressIndicator(minHeight: 2, color: AppColors.accent),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Text('\$', style: TextStyle(color: AppColors.accent, fontFamily: 'monospace')),
                const SizedBox(width: 6),
                Expanded(
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (_) {},
                    child: TextField(
                      controller: _inputController,
                      style: AppTheme.editorFont(fontSize: 13),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Type a command…',
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16, color: AppColors.textMuted),
                  onPressed: _historyUp,
                  tooltip: 'Command history',
                ),
                IconButton(
                  icon: const Icon(Icons.send, size: 18, color: AppColors.accent),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
