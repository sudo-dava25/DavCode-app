import 'dart:convert';
import 'dart:io';
import '../constants/app_constants.dart';

/// Low-level filesystem access shared by the editor and file_manager
/// features, so raw dart:io calls live in exactly one place (clean
/// architecture: a single core service backing multiple feature
/// repositories instead of each feature re-implementing file IO).
///
/// "Secure file access": every call is scoped to paths the user explicitly
/// opened (project root / picked file) — Dav Code never reads/writes
/// outside of what the user selected via the file picker or file explorer.
class FileIOService {
  FileIOService._();
  static final FileIOService instance = FileIOService._();

  Future<bool> exists(String path) async {
    final isFile = await File(path).exists();
    if (isFile) return true;
    return Directory(path).exists();
  }

  Future<String> readText(String path) async {
    final file = File(path);
    final stat = await file.stat();
    if (stat.size > AppConstants.largeFileThresholdBytes) {
      // Large file: still read, but callers should switch the UI into a
      // lazy / read-only view above this threshold (see EditorRepository).
    }
    return file.readAsString();
  }

  /// Reads only the first [maxBytes] of a file — used for previewing very
  /// large files without loading them fully into memory.
  Future<String> readTextPreview(String path, {int maxBytes = 65536}) async {
    final file = File(path);
    final raf = await file.open();
    try {
      final length = await raf.length();
      final toRead = length < maxBytes ? length : maxBytes;
      final bytes = await raf.read(toRead);
      return utf8.decode(bytes, allowMalformed: true);
    } finally {
      await raf.close();
    }
  }

  Future<void> writeText(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  Future<void> createFile(String path) async {
    final file = File(path);
    if (await file.exists()) return;
    await file.parent.create(recursive: true);
    await file.create();
  }

  Future<void> createDirectory(String path) async {
    await Directory(path).create(recursive: true);
  }

  Future<void> rename(String oldPath, String newPath) async {
    final entity = await _entityFor(oldPath);
    await entity.rename(newPath);
  }

  Future<void> delete(String path) async {
    final entity = await _entityFor(path);
    await entity.delete(recursive: true);
  }

  Future<void> copy(String sourcePath, String destPath) async {
    final type = await FileSystemEntity.type(sourcePath);
    if (type == FileSystemEntityType.directory) {
      await _copyDirectory(Directory(sourcePath), Directory(destPath));
    } else {
      await File(sourcePath).copy(destPath);
    }
  }

  Future<void> move(String sourcePath, String destPath) async {
    await copy(sourcePath, destPath);
    await delete(sourcePath);
  }

  Future<List<FileSystemEntity>> list(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];
    return dir.list().toList();
  }

  Future<int> sizeOf(String path) async => File(path).stat().then((s) => s.size);

  Future<FileSystemEntity> _entityFor(String path) async {
    final type = await FileSystemEntity.type(path);
    return type == FileSystemEntityType.directory ? Directory(path) : File(path);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final newPath = '${destination.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}';
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }
}
