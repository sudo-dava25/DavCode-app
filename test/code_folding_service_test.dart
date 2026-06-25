import 'package:flutter_test/flutter_test.dart';
import 'package:dav_code/features/editor/data/services/code_folding_service.dart';

void main() {
  final folding = CodeFoldingService();

  test('detects a foldable region spanning multiple lines', () {
    const source = 'class Foo {\n  void bar() {\n    print(1);\n  }\n}';
    final regions = folding.computeFoldableRegions(source);
    expect(regions, isNotEmpty);
    expect(regions.first.startLine, 0);
    expect(regions.first.endLine, 4);
  });

  test('ignores brace pairs that stay on a single line', () {
    const source = 'final map = {"a": 1};';
    final regions = folding.computeFoldableRegions(source);
    expect(regions, isEmpty);
  });
}
