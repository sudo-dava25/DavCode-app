/// A foldable region spanning from [startLine] (the line containing the
/// opening bracket, 0-indexed) to [endLine] (the line containing the
/// closing bracket).
class FoldRegion {
  final int startLine;
  final int endLine;
  const FoldRegion(this.startLine, this.endLine);
}

/// Computes foldable regions from brace/bracket nesting and produces a
/// "folded" version of the document for display, implementing the
/// "Code folding" requirement.
///
/// Design note: folding is implemented at the line level rather than via a
/// rope/piece-table (what production editors like VS Code use), which is
/// the right scope for a mobile IDE scaffold. The placeholder line keeps a
/// stable marker so unfolding can restore the exact original content.
class CodeFoldingService {
  static const String foldMarkerPrefix = '⟦folded:';
  static const String foldMarkerSuffix = '⟧';

  /// Scans [source] for `{ }`, `( )`, `[ ]` pairs that span more than one
  /// line and returns one [FoldRegion] per such pair.
  List<FoldRegion> computeFoldableRegions(String source) {
    final lines = source.split('\n');
    final regions = <FoldRegion>[];
    final openStack = <_OpenBracket>[];

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      var inString = false;
      String? stringChar;
      for (var i = 0; i < line.length; i++) {
        final ch = line[i];
        if (inString) {
          if (ch == stringChar && (i == 0 || line[i - 1] != '\\')) inString = false;
          continue;
        }
        if (ch == '"' || ch == "'") {
          inString = true;
          stringChar = ch;
          continue;
        }
        if (ch == '{' || ch == '(' || ch == '[') {
          openStack.add(_OpenBracket(ch, lineIndex));
        } else if (ch == '}' || ch == ')' || ch == ']') {
          if (openStack.isNotEmpty) {
            final open = openStack.removeLast();
            if (lineIndex > open.line) {
              regions.add(FoldRegion(open.line, lineIndex));
            }
          }
        }
      }
    }
    regions.sort((a, b) => a.startLine.compareTo(b.startLine));
    return regions;
  }

  /// Replaces each folded region's inner lines with a single placeholder
  /// line so the editor can render a collapsed view while keeping the
  /// underlying [source] untouched (the caller decides whether to persist
  /// the collapsed or original text — normally only the original is saved).
  String buildCollapsedText(String source, Set<int> foldedStartLines, List<FoldRegion> allRegions) {
    final lines = source.split('\n');
    final regionsByStart = {for (final r in allRegions) r.startLine: r};
    final output = <String>[];

    var i = 0;
    while (i < lines.length) {
      final region = regionsByStart[i];
      if (region != null && foldedStartLines.contains(i)) {
        final hiddenLineCount = region.endLine - region.startLine;
        output.add('${lines[i]} $foldMarkerPrefix$hiddenLineCount lines$foldMarkerSuffix');
        i = region.endLine + 1;
      } else {
        output.add(lines[i]);
        i++;
      }
    }
    return output.join('\n');
  }
}

class _OpenBracket {
  final String char;
  final int line;
  _OpenBracket(this.char, this.line);
}
