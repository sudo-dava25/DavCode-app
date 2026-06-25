import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/workspace.dart';

/// Implements "Save workspace" / "Recent projects" / "Open project" on top
/// of Hive (via StorageService), so projects survive app restarts.
class WorkspaceService {
  final StorageService _storage;
  final _uuid = const Uuid();

  WorkspaceService({StorageService? storage}) : _storage = storage ?? StorageService.instance;

  List<Workspace> getRecentProjects() {
    final box = _storage.recentProjects;
    final items = box.values
        .map((raw) => Workspace.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
    items.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return items;
  }

  Future<Workspace> openProject(String rootPath, {String? name}) async {
    final box = _storage.recentProjects;
    final existing = box.values.cast<Map?>().firstWhere(
          (m) => m != null && m['rootPath'] == rootPath,
          orElse: () => null,
        );

    final workspace = Workspace(
      id: existing != null ? existing['id'] as String : _uuid.v4(),
      rootPath: rootPath,
      name: name ?? rootPath.split('/').where((s) => s.isNotEmpty).last,
      lastOpened: DateTime.now(),
    );

    await box.put(workspace.id, workspace.toMap());
    await _pruneOldEntries();
    return workspace;
  }

  Future<void> removeProject(String id) async {
    await _storage.recentProjects.delete(id);
  }

  Future<void> _pruneOldEntries() async {
    final box = _storage.recentProjects;
    if (box.length <= AppConstants.maxRecentProjects) return;
    final items = getRecentProjects();
    final toRemove = items.skip(AppConstants.maxRecentProjects);
    for (final w in toRemove) {
      await box.delete(w.id);
    }
  }
}
