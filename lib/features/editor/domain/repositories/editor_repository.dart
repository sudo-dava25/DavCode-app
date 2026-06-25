/// Abstract contract for reading/writing the content an EditorTab needs.
/// Kept narrow on purpose (Interface Segregation) — the editor feature only
/// needs read/write/exists, not the full file-management API that
/// features/file_manager exposes.
abstract class EditorRepository {
  Future<String> readFile(String path);
  Future<String> readFilePreview(String path, {int maxBytes});
  Future<void> writeFile(String path, String content);
  Future<int> fileSize(String path);
}
