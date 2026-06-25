import 'package:flutter_test/flutter_test.dart';
import 'package:dav_code/features/editor/data/services/auto_indent_service.dart';

void main() {
  final indent = AutoIndentService();

  test('widens indent after a line ending with an opening brace', () {
    const before = 'void main() {';
    final result = indent.indentForNewLine(before, tabSize: 2, useSpaces: true);
    expect(result, '  ');
  });

  test('keeps the same indent for a plain statement line', () {
    const before = '  final x = 1;';
    final result = indent.indentForNewLine(before, tabSize: 2, useSpaces: true);
    expect(result, '  ');
  });

  test('widens indent after a Python-style colon block opener', () {
    const before = 'def foo():';
    final result = indent.indentForNewLine(before, tabSize: 4, useSpaces: true);
    expect(result, '    ');
  });
}
