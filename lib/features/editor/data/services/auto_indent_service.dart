/// Computes the indentation to insert when the user presses Enter,
/// implementing the "Auto indentation" requirement. Also widens indent
/// after lines ending in an opening bracket / colon (Python-style blocks).
class AutoIndentService {
  String indentForNewLine(String textBeforeCursor, {required int tabSize, required bool useSpaces}) {
    final lastNewline = textBeforeCursor.lastIndexOf('\n');
    final currentLine = lastNewline == -1
        ? textBeforeCursor
        : textBeforeCursor.substring(lastNewline + 1);

    final leadingWhitespace = RegExp(r'^[ \t]*').firstMatch(currentLine)?.group(0) ?? '';
    final trimmed = currentLine.trimRight();

    final unit = useSpaces ? ' ' * tabSize : '\t';
    final opensBlock = trimmed.endsWith('{') ||
        trimmed.endsWith('(') ||
        trimmed.endsWith('[') ||
        trimmed.endsWith(':'); // Python-style block opener

    return opensBlock ? '$leadingWhitespace$unit' : leadingWhitespace;
  }

  /// When the user types a closing bracket immediately after auto-indent
  /// produced extra indentation, this dedents the closing bracket's line
  /// to match its opening line (common "smart bracket" behavior).
  String dedentForClosingBracket(String currentLineWhitespace, {required int tabSize, required bool useSpaces}) {
    final unit = useSpaces ? ' ' * tabSize : '\t';
    if (currentLineWhitespace.endsWith(unit)) {
      return currentLineWhitespace.substring(0, currentLineWhitespace.length - unit.length);
    }
    return currentLineWhitespace;
  }
}
