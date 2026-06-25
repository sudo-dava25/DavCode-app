import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/code_folding_service.dart';

/// Renders the "Line number" gutter, plus fold/unfold chevrons next to
/// lines that start a foldable region ("Code folding" requirement).
class LineNumberGutter extends StatelessWidget {
  final int lineCount;
  final double fontSize;
  final List<FoldRegion> foldableRegions;
  final Set<int> foldedStartLines;
  final void Function(int lineIndex) onToggleFold;
  final Set<int> errorLines;

  const LineNumberGutter({
    super.key,
    required this.lineCount,
    required this.fontSize,
    required this.foldableRegions,
    required this.foldedStartLines,
    required this.onToggleFold,
    this.errorLines = const {},
  });

  @override
  Widget build(BuildContext context) {
    final foldStartLines = {for (final r in foldableRegions) r.startLine: r};
    final lineHeight = fontSize * 1.5;

    return Container(
      width: 52,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(lineCount, (i) {
          final hasFold = foldStartLines.containsKey(i);
          final isFolded = foldedStartLines.contains(i);
          final hasError = errorLines.contains(i);
          return SizedBox(
            height: lineHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasError)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  ),
                Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: fontSize * 0.85,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: hasFold
                      ? InkWell(
                          onTap: () => onToggleFold(i),
                          child: Icon(
                            isFolded ? Icons.chevron_right : Icons.expand_more,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
