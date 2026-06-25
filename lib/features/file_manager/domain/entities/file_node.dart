import 'package:equatable/equatable.dart';

enum FileNodeType { file, directory }

/// Represents one entry in the file explorer tree.
class FileNode extends Equatable {
  final String path;
  final String name;
  final FileNodeType type;
  final int sizeBytes;
  final DateTime modified;

  const FileNode({
    required this.path,
    required this.name,
    required this.type,
    this.sizeBytes = 0,
    required this.modified,
  });

  bool get isDirectory => type == FileNodeType.directory;

  @override
  List<Object?> get props => [path, type, sizeBytes, modified];
}
