/// Finds the matching bracket for a given cursor position, powering the
/// "Bracket matching" requirement (e.g. highlighting the matching `}` when
/// the cursor is right after `{`).
class BracketMatcherService {
  static const Map<String, String> _openToClose = {'(': ')', '[': ']', '{': '}'};
  static const Map<String, String> _closeToOpen = {')': '(', ']': '[', '}': '{'};

  /// Returns the offset of the matching bracket for the character touching
  /// [cursorOffset], or null if the cursor isn't adjacent to a bracket or
  /// no match is found.
  int? findMatch(String text, int cursorOffset) {
    if (text.isEmpty) return null;

    // Check character right before the cursor, then right after.
    for (final probe in [cursorOffset - 1, cursorOffset]) {
      if (probe < 0 || probe >= text.length) continue;
      final ch = text[probe];
      if (_openToClose.containsKey(ch)) {
        return _scanForward(text, probe, ch, _openToClose[ch]!);
      }
      if (_closeToOpen.containsKey(ch)) {
        return _scanBackward(text, probe, _closeToOpen[ch]!, ch);
      }
    }
    return null;
  }

  int? _scanForward(String text, int start, String open, String close) {
    var depth = 0;
    for (var i = start; i < text.length; i++) {
      if (text[i] == open) depth++;
      if (text[i] == close) {
        depth--;
        if (depth == 0) return i;
      }
    }
    return null;
  }

  int? _scanBackward(String text, int start, String open, String close) {
    var depth = 0;
    for (var i = start; i >= 0; i--) {
      if (text[i] == close) depth++;
      if (text[i] == open) {
        depth--;
        if (depth == 0) return i;
      }
    }
    return null;
  }
}
