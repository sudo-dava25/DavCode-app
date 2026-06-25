import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart' as hl;
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/markdown.dart';
import '../../../../core/theme/app_colors.dart';

/// Wraps package:highlight to turn raw source into colored [TextSpan]s,
/// satisfying the "Syntax highlighting" requirement for all supported
/// languages. Each language only needs registering once below — adding a
/// new language is a 2-line addition (import + registerLanguage call).
class SyntaxHighlighterService {
  SyntaxHighlighterService._() {
    _registerLanguages();
  }

  static final SyntaxHighlighterService instance = SyntaxHighlighterService._();

  bool _registered = false;

  void _registerLanguages() {
    if (_registered) return;
    hl.highlight.registerLanguage('dart', dart);
    hl.highlight.registerLanguage('kotlin', kotlin);
    hl.highlight.registerLanguage('java', java);
    hl.highlight.registerLanguage('javascript', javascript);
    hl.highlight.registerLanguage('typescript', typescript);
    hl.highlight.registerLanguage('python', python);
    // package:highlight has no standalone C grammar — register 'c' as an
    // alias for the C++ grammar, which highlights C source correctly
    // since C syntax is (for highlighting purposes) a subset of C++.
    hl.highlight.registerLanguage('c', cpp);
    hl.highlight.registerLanguage('cpp', cpp);
    hl.highlight.registerLanguage('xml', xml);
    hl.highlight.registerLanguage('css', css);
    hl.highlight.registerLanguage('json', json);
    hl.highlight.registerLanguage('bash', bash);
    hl.highlight.registerLanguage('yaml', yaml);
    hl.highlight.registerLanguage('markdown', markdown);
    _registered = true;
  }

  /// Maps a highlight.js-style class name to a color from AppColors.
  Color _colorFor(String? className) {
    switch (className) {
      case 'keyword':
      case 'built_in':
      case 'literal':
        return AppColors.syntaxKeyword;
      case 'string':
      case 'symbol':
        return AppColors.syntaxString;
      case 'comment':
      case 'quote':
        return AppColors.syntaxComment;
      case 'number':
        return AppColors.syntaxNumber;
      case 'function':
      case 'title':
      case 'title.function':
        return AppColors.syntaxFunction;
      case 'class':
      case 'type':
      case 'title.class':
        return AppColors.syntaxType;
      case 'operator':
      case 'punctuation':
        return AppColors.syntaxOperator;
      case 'variable':
      case 'attr':
      case 'params':
        return AppColors.syntaxVariable;
      default:
        return AppColors.textPrimary;
    }
  }

  /// Highlights [source] for [languageKey] (e.g. 'dart', 'python') and
  /// returns spans ready to drop into a RichText/TextSpan tree.
  List<TextSpan> highlight(String source, String languageKey, {required TextStyle baseStyle}) {
    if (languageKey == 'plaintext' || source.isEmpty) {
      return [TextSpan(text: source, style: baseStyle)];
    }
    try {
      final result = hl.highlight.parse(source, language: languageKey);
      final nodes = result.nodes ?? [];
      final spans = <TextSpan>[];
      _convertNodes(nodes, baseStyle, spans);
      return spans.isEmpty ? [TextSpan(text: source, style: baseStyle)] : spans;
    } catch (_) {
      // Never let a highlighting failure break the editor — fall back to
      // plain (un-highlighted) text.
      return [TextSpan(text: source, style: baseStyle)];
    }
  }

  void _convertNodes(List<hl.Node> nodes, TextStyle baseStyle, List<TextSpan> out, [String? parentClass]) {
    for (final node in nodes) {
      if (node.value != null) {
        out.add(TextSpan(
          text: node.value,
          style: baseStyle.copyWith(color: _colorFor(node.className ?? parentClass)),
        ));
      } else if (node.children != null) {
        final children = <TextSpan>[];
        _convertNodes(node.children!, baseStyle, children, node.className ?? parentClass);
        out.add(TextSpan(children: children));
      }
    }
  }
}
