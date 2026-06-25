import 'package:equatable/equatable.dart';
import '../../../../core/constants/supported_languages.dart';

/// Represents one open file tab in the editor (supports the
/// "Multiple file tabs" requirement).
class EditorTab extends Equatable {
  final String id;
  final String filePath;
  final String fileName;
  final LanguageInfo language;
  final String content;
  final bool isDirty;
  final bool isReadOnlyLargeFile;
  final int cursorOffset;

  const EditorTab({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.language,
    required this.content,
    this.isDirty = false,
    this.isReadOnlyLargeFile = false,
    this.cursorOffset = 0,
  });

  EditorTab copyWith({
    String? content,
    bool? isDirty,
    int? cursorOffset,
  }) {
    return EditorTab(
      id: id,
      filePath: filePath,
      fileName: fileName,
      language: language,
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
      isReadOnlyLargeFile: isReadOnlyLargeFile,
      cursorOffset: cursorOffset ?? this.cursorOffset,
    );
  }

  @override
  List<Object?> get props => [id, filePath, content, isDirty, cursorOffset];
}
