import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ai_providers.dart';

/// Bottom sheet exposing the AI quick actions that act on a code
/// selection: Explain, Generate, Find bugs, Refactor. Call this from the
/// editor toolbar with the selected (or whole-file) code.
class CodeActionSheet {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String code,
    required String language,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            _tile(ctx, Icons.lightbulb_outline, 'Explain code', 'explain'),
            _tile(ctx, Icons.auto_fix_high, 'Refactor code', 'refactor'),
            _tile(ctx, Icons.bug_report_outlined, 'Find bugs', 'findBugs'),
            _tile(ctx, Icons.add_box_outlined, 'Generate from this', 'generate'),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => const _AiResultDialog(loading: true),
    );

    try {
      final result = await ref.read(aiQuickActionProvider)(
        action: action,
        code: code,
        language: language,
      );
      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog
      showDialog(context: context, builder: (_) => _AiResultDialog(result: result));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(context: context, builder: (_) => _AiResultDialog(error: e.toString()));
    }
  }

  static Widget _tile(BuildContext ctx, IconData icon, String label, String action) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label),
      onTap: () => Navigator.pop(ctx, action),
    );
  }
}

class _AiResultDialog extends StatelessWidget {
  final bool loading;
  final String? result;
  final String? error;

  const _AiResultDialog({this.loading = false, this.result, this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Assistant'),
      content: SizedBox(
        width: double.maxFinite,
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: SelectableText(
                  error ?? result ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: error != null ? AppColors.error : AppColors.textPrimary,
                    fontFamily: error == null ? 'monospace' : null,
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
