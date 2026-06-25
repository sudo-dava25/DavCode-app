import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/file_explorer_providers.dart';

/// Shown when no project is open: lets the user open a new project folder
/// or jump back into a recent one ("Recent projects" / "Open project").
class RecentProjectsScreen extends ConsumerWidget {
  const RecentProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dav Code')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProject(context, ref),
        icon: const Icon(Icons.folder_open),
        label: const Text('Open Project'),
      ),
      body: recents.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, size: 56, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('No projects yet', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 6),
                    Text(
                      'Tap "Open Project" to browse storage and pick a\nproject folder to start coding.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: recents.length,
              itemBuilder: (context, index) {
                final project = recents[index];
                return ListTile(
                  leading: const Icon(Icons.folder, color: AppColors.accent),
                  title: Text(project.name),
                  subtitle: Text(
                    project.rootPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: Text(
                    DateFormat.MMMd().format(project.lastOpened),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () => _openExisting(ref, project.rootPath),
                  onLongPress: () => _confirmRemove(context, ref, project.id),
                );
              },
            ),
    );
  }

  Future<void> _openProject(BuildContext context, WidgetRef ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final granted = await permissionService.requestStorageAccess();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to open a project.')),
        );
      }
      return;
    }

    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    await _openExisting(ref, result);
  }

  Future<void> _openExisting(WidgetRef ref, String path) async {
    final workspace = await ref.read(workspaceServiceProvider).openProject(path);
    ref.read(currentWorkspaceProvider.notifier).state = workspace;
    ref.read(recentProjectsProvider.notifier).state =
        ref.read(workspaceServiceProvider).getRecentProjects();
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from recent?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(workspaceServiceProvider).removeProject(id);
      ref.read(recentProjectsProvider.notifier).state =
          ref.read(workspaceServiceProvider).getRecentProjects();
    }
  }
}
