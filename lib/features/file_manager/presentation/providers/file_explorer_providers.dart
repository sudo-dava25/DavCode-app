import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/file_repository_impl.dart';
import '../../data/services/permission_service.dart';
import '../../data/services/workspace_service.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/repositories/file_repository.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) => FileRepositoryImpl());
final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService());
final workspaceServiceProvider = Provider<WorkspaceService>((ref) => WorkspaceService());

/// Currently opened project root (null = no project open yet).
final currentWorkspaceProvider = StateProvider<Workspace?>((ref) => null);

/// Recent projects list (read from Hive via WorkspaceService).
final recentProjectsProvider = StateProvider<List<Workspace>>((ref) {
  return ref.read(workspaceServiceProvider).getRecentProjects();
});

/// Set of directory paths currently expanded in the file tree.
final expandedDirsProvider = StateProvider<Set<String>>((ref) => {});

/// Loads (and caches) the children of one directory — kept as a FutureProvider
/// family so each directory is fetched lazily ("Lazy loading file"
/// performance requirement) only when the user expands it.
final directoryChildrenProvider = FutureProvider.family<List<FileNode>, String>((ref, path) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.listDirectory(path);
});

/// Bumping this provider's state invalidates directoryChildrenProvider for
/// the affected path, refreshing the tree after create/delete/rename/move.
void refreshDirectory(WidgetRef ref, String path) {
  ref.invalidate(directoryChildrenProvider(path));
}
