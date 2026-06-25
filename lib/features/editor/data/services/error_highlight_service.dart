/// A lightweight, language-agnostic linter used for the "Error highlighting"
/// requirement. It does NOT replace a real compiler/analyzer — it catches
/// the cheap, common mistakes (unbalanced brackets, unterminated strings)
/// that are useful to flag immediately while typing on a phone.
///
/// Extension point: for deeper diagnostics (e.g. full Dart analysis), wire
/// in `dart analyze` output (via the terminal/runner system) and feed its
/// line numbers into the same `Set<int>` this service returns.
class ErrorHighlightService {
  Set<int> findErrorLines(String source) {
    final errorLines = <int>{};
    final lines = source.split('\n');
    final stack = <_BracketAt>[];
    const pairs = {'(': ')', '[': ']', '{': '}'};
    const closers = {')': '(', ']': '[', '}': '{'};

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      bool inString = false;
      String? quoteChar;
      for (var i = 0; i < line.length; i++) {
        final ch = line[i];
        if (inString) {
          if (ch == quoteChar && (i == 0 || line[i - 1] != '\\')) inString = false;
          continue;
        }
        if (ch == '"' || ch == "'") {
          inString = true;
          quoteChar = ch;
          continue;
        }
        if (pairs.containsKey(ch)) {
          stack.add(_BracketAt(ch, lineIndex));
        } else if (closers.containsKey(ch)) {
          if (stack.isEmpty || pairs[stack.last.char] != ch) {
            errorLines.add(lineIndex);
          } else {
            stack.removeLast();
          }
        }
      }
      if (inString) errorLines.add(lineIndex); // unterminated string literal
    }
    for (final unclosed in stack) {
      errorLines.add(unclosed.line);
    }
    return errorLines;
  }
}

class _BracketAt {
  final String char;
  final int line;
  _BracketAt(this.char, this.line);
}
