import '../entities/file_node.dart';

/// Contract for everything the "FILE MANAGER" requirements ask for:
/// browse, create, rename, delete, copy, move. Implemented by
/// FileRepositoryImpl using the shared core FileIOService.
abstract class FileRepository {
  Future<List<FileNode>> listDirectory(String path);
  Future<void> createFile(String path);
  Future<void> createFolder(String path);
  Future<void> rename(String path, String newPath);
  Future<void> delete(String path);
  Future<void> copy(String sourcePath, String destPath);
  Future<void> move(String sourcePath, String destPath);
  Future<bool> exists(String path);
}
