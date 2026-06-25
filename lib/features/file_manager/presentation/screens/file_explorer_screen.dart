import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../editor/presentation/providers/editor_providers.dart';
import '../../domain/entities/file_node.dart';
import '../providers/file_explorer_providers.dart';
import '../widgets/file_tree_item.dart';
import '../widgets/new_file_dialog.dart';
import 'recent_projects_screen.dart';

/// The "FILE MANAGER" screen: a project tree the user can browse, create
/// files/folders in, rename, delete, copy, and move — tapping a file opens
/// it in the Editor tab.
class FileExplorerScreen extends ConsumerWidget {
  const FileExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);

    if (workspace == null) {
      return const RecentProjectsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workspace.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'New file',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () => _createEntry(context, ref, workspace.rootPath, isFolder: false),
          ),
          IconButton(
            tooltip: 'New folder',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createEntry(context, ref, workspace.rootPath, isFolder: true),
          ),
          IconButton(
            tooltip: 'Switch project',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => ref.read(currentWorkspaceProvider.notifier).state = null,
          ),
        ],
      ),
      body: _DirectoryNode(path: workspace.rootPath, depth: 0),
    );
  }

  Future<void> _createEntry(BuildContext context, WidgetRef ref, String dirPath, {required bool isFolder}) async {
    final name = await NameInputDialog.show(
      context,
      title: isFolder ? 'New folder' : 'New file',
      confirmLabel: 'Create',
    );
    if (name == null || name.isEmpty) return;
    final repo = ref.read(fileRepositoryProvider);
    final path = FileUtils.join(dirPath, name);
    if (isFolder) {
      await repo.createFolder(path);
    } else {
      await repo.createFile(path);
    }
    refreshDirectory(ref, dirPath);
  }
}

class _DirectoryNode extends ConsumerWidget {
  final String path;
  final int depth;

  const _DirectoryNode({required this.path, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(directoryChildrenProvider(path));

    return childrenAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to read folder: $err', style: const TextStyle(color: AppColors.error)),
      ),
      data: (nodes) => ListView.builder(
        shrinkWrap: depth > 0,
        physics: depth > 0 ? const NeverScrollableScrollPhysics() : null,
        itemCount: nodes.length,
        itemBuilder: (context, index) => _NodeRow(node: nodes[index], depth: depth),
      ),
    );
  }
}

class _NodeRow extends ConsumerWidget {
  final FileNode node;
  final int depth;

  const _NodeRow({required this.node, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(expandedDirsProvider).contains(node.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FileTreeItem(
          node: node,
          depth: depth,
          isExpanded: expanded,
          onTap: () => _handleTap(context, ref),
          onAction: (action) => _handleAction(context, ref, action),
        ),
        if (node.isDirectory && expanded)
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: _DirectoryNode(path: node.path, depth: depth + 1),
          ),
      ],
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (node.isDirectory) {
      final set = {...ref.read(expandedDirsProvider)};
      if (set.contains(node.path)) {
        set.remove(node.path);
      } else {
        set.add(node.path);
      }
      ref.read(expandedDirsProvider.notifier).state = set;
    } else {
      ref.read(editorTabsProvider.notifier).openFile(node.path);
      // Jump the bottom nav to the Editor tab on mobile (index 0).
      ref.read(activeBottomTabProvider.notifier).state = 0;
    }
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(fileRepositoryProvider);
    final parent = FileUtils.parentDir(node.path);
    switch (action) {
      case 'rename':
        final newName = await NameInputDialog.show(
          context,
          title: 'Rename',
          initialValue: node.name,
          confirmLabel: 'Rename',
        );
        if (newName != null && newName.isNotEmpty) {
          await repo.rename(node.path, FileUtils.join(parent, newName));
          refreshDirectory(ref, parent);
        }
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete?'),
            content: Text('Delete "${node.name}"? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.delete(node.path);
          refreshDirectory(ref, parent);
        }
        break;
      case 'copy':
        final newName = await NameInputDialog.show(
          context,
          title: 'Copy as',
          initialValue: '${node.name}_copy',
          confirmLabel: 'Copy',
        );
        if (newName != null && newName.isNotEmpty) {
          await repo.copy(node.path, FileUtils.join(parent, newName));
          refreshDirectory(ref, parent);
        }
        break;
      case 'move':
        final newPath = await NameInputDialog.show(
          context,
          title: 'Move to (full path)',
          initialValue: node.path,
          confirmLabel: 'Move',
        );
        if (newPath != null && newPath.isNotEmpty && newPath != node.path) {
          await repo.move(node.path, newPath);
          refreshDirectory(ref, parent);
        }
        break;
    }
  }
}

