/// Languages supported by the editor, terminal runners, and syntax
/// highlighter. Adding a new language = adding one entry here +
/// (optionally) a Runner implementation in features/terminal/data/runners.
enum CodeLanguage {
  dart,
  kotlin,
  java,
  javascript,
  typescript,
  python,
  c,
  cpp,
  html,
  css,
  json,
  xml,
  shell,
  yaml,
  markdown,
  plainText,
}

class LanguageInfo {
  final CodeLanguage language;
  final String label;
  final List<String> extensions;
  final String highlightModeKey; // key understood by package:highlight

  const LanguageInfo({
    required this.language,
    required this.label,
    required this.extensions,
    required this.highlightModeKey,
  });
}

class SupportedLanguages {
  SupportedLanguages._();

  static const List<LanguageInfo> all = [
    LanguageInfo(language: CodeLanguage.dart, label: 'Dart', extensions: ['.dart'], highlightModeKey: 'dart'),
    LanguageInfo(language: CodeLanguage.kotlin, label: 'Kotlin', extensions: ['.kt', '.kts'], highlightModeKey: 'kotlin'),
    LanguageInfo(language: CodeLanguage.java, label: 'Java', extensions: ['.java'], highlightModeKey: 'java'),
    LanguageInfo(language: CodeLanguage.javascript, label: 'JavaScript', extensions: ['.js', '.mjs', '.cjs'], highlightModeKey: 'javascript'),
    LanguageInfo(language: CodeLanguage.typescript, label: 'TypeScript', extensions: ['.ts', '.tsx'], highlightModeKey: 'typescript'),
    LanguageInfo(language: CodeLanguage.python, label: 'Python', extensions: ['.py'], highlightModeKey: 'python'),
    LanguageInfo(language: CodeLanguage.c, label: 'C', extensions: ['.c', '.h'], highlightModeKey: 'c'),
    LanguageInfo(language: CodeLanguage.cpp, label: 'C++', extensions: ['.cpp', '.cc', '.hpp', '.hh'], highlightModeKey: 'cpp'),
    LanguageInfo(language: CodeLanguage.html, label: 'HTML', extensions: ['.html', '.htm'], highlightModeKey: 'xml'),
    LanguageInfo(language: CodeLanguage.css, label: 'CSS', extensions: ['.css'], highlightModeKey: 'css'),
    LanguageInfo(language: CodeLanguage.json, label: 'JSON', extensions: ['.json'], highlightModeKey: 'json'),
    LanguageInfo(language: CodeLanguage.xml, label: 'XML', extensions: ['.xml'], highlightModeKey: 'xml'),
    LanguageInfo(language: CodeLanguage.shell, label: 'Shell Script', extensions: ['.sh', '.bash'], highlightModeKey: 'bash'),
    LanguageInfo(language: CodeLanguage.yaml, label: 'YAML', extensions: ['.yaml', '.yml'], highlightModeKey: 'yaml'),
    LanguageInfo(language: CodeLanguage.markdown, label: 'Markdown', extensions: ['.md'], highlightModeKey: 'markdown'),
  ];

  static LanguageInfo fromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    for (final info in all) {
      for (final ext in info.extensions) {
        if (lower.endsWith(ext)) return info;
      }
    }
    return const LanguageInfo(
      language: CodeLanguage.plainText,
      label: 'Plain Text',
      extensions: [],
      highlightModeKey: 'plaintext',
    );
  }
}
