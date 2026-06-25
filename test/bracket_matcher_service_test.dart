import 'package:flutter_test/flutter_test.dart';
import 'package:dav_code/features/editor/data/services/bracket_matcher_service.dart';

void main() {
  final matcher = BracketMatcherService();

  test('finds matching closing brace from cursor right after opening brace', () {
    const text = 'void main() {\n  print("hi");\n}';
    final openOffset = text.indexOf('{');
    final match = matcher.findMatch(text, openOffset + 1);
    expect(match, text.lastIndexOf('}'));
  });

  test('finds matching opening paren from cursor right after closing paren', () {
    const text = '(a + (b * c))';
    const closeOffset = text.length; // cursor at very end, right after final ')'
    final match = matcher.findMatch(text, closeOffset);
    expect(match, 0);
  });

  test('returns null when cursor is not adjacent to any bracket', () {
    const text = 'hello world';
    expect(matcher.findMatch(text, 5), isNull);
  });
}
