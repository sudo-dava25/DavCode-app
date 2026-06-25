import 'dart:io';
import '../../../../core/services/file_io_service.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FileIOService _fileIO;

  FileRepositoryImpl({FileIOService? fileIO}) : _fileIO = fileIO ?? FileIOService.instance;

  @override
  Future<List<FileNode>> listDirectory(String path) async {
    final entities = await _fileIO.list(path);
    final nodes = <FileNode>[];
    for (final entity in entities) {
      final stat = await entity.stat();
      final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
      // Skip hidden/system noise by default; explorer UI can add a
      // "show hidden files" toggle later without changing this layer.
      nodes.add(FileNode(
        path: entity.path,
        name: name,
        type: entity is Directory ? FileNodeType.directory : FileNodeType.file,
        sizeBytes: stat.size,
        modified: stat.modified,
      ));
    }
    // Folders first, then files, both alphabetical — standard IDE ordering.
    nodes.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return nodes;
  }

  @override
  Future<void> createFile(String path) => _fileIO.createFile(path);

  @override
  Future<void> createFolder(String path) => _fileIO.createDirectory(path);

  @override
  Future<void> rename(String path, String newPath) => _fileIO.rename(path, newPath);

  @override
  Future<void> delete(String path) => _fileIO.delete(path);

  @override
  Future<void> copy(String sourcePath, String destPath) => _fileIO.copy(sourcePath, destPath);

  @override
  Future<void> move(String sourcePath, String destPath) => _fileIO.move(sourcePath, destPath);

  @override
  Future<bool> exists(String path) => _fileIO.exists(path);
}
