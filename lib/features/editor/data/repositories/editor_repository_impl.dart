import '../../../../core/services/file_io_service.dart';
import '../../domain/repositories/editor_repository.dart';

/// Default implementation — delegates to the shared core FileIOService.
class EditorRepositoryImpl implements EditorRepository {
  final FileIOService _fileIO;

  EditorRepositoryImpl({FileIOService? fileIO}) : _fileIO = fileIO ?? FileIOService.instance;

  @override
  Future<String> readFile(String path) => _fileIO.readText(path);

  @override
  Future<String> readFilePreview(String path, {int maxBytes = 65536}) =>
      _fileIO.readTextPreview(path, maxBytes: maxBytes);

  @override
  Future<void> writeFile(String path, String content) => _fileIO.writeText(path, content);

  @override
  Future<int> fileSize(String path) => _fileIO.sizeOf(path);
}
