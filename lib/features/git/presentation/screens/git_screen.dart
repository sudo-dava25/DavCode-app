import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../file_manager/presentation/providers/file_explorer_providers.dart';
import '../providers/git_providers.dart';
import '../widgets/commit_dialog.dart';
import '../widgets/git_status_list.dart';

/// "GIT INTEGRATION" screen: status, stage/commit, push/pull, branches,
/// and recent commit log for the currently open project.
class GitScreen extends ConsumerStatefulWidget {
  const GitScreen({super.key});

  @override
  ConsumerState<GitScreen> createState() => _GitScreenState();
}

class _GitScreenState extends ConsumerState<GitScreen> {
  String? _boundPath;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final gitState = ref.watch(gitNotifierProvider);
    final gitNotifier = ref.read(gitNotifierProvider.notifier);

    if (workspace == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Git'),
          leading: Responsive.isDesktop(context)
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => ref.read(homeScaffoldKeyProvider).currentState?.openDrawer(),
                ),
        ),
        body: const Center(
          child: Text('Open a project first', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    if (_boundPath != workspace.rootPath) {
      _boundPath = workspace.rootPath;
      Future.microtask(() => gitNotifier.bind(workspace.rootPath));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Git'),
        leading: Responsive.isDesktop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref.read(homeScaffoldKeyProvider).currentState?.openDrawer(),
              ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: gitNotifier.refresh),
        ],
      ),
      body: gitState.loading
          ? const Center(child: CircularProgressIndicator())
          : !gitState.isRepo
              ? _NotARepoView(onInit: gitNotifier.initRepo)
              : RefreshIndicator(
                  onRefresh: gitNotifier.refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (gitState.error != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(gitState.error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ),
                      _ActionsRow(
                        onStageAll: gitNotifier.stageAll,
                        onCommit: () async {
                          final message = await CommitDialog.show(context);
                          if (message != null && message.isNotEmpty) {
                            await gitNotifier.commit(message);
                          }
                        },
                        onPush: gitNotifier.push,
                        onPull: gitNotifier.pull,
                      ),
                      const SizedBox(height: 16),
                      Text('Branch: ${gitState.branches.where((b) => b.isCurrent).map((b) => b.name).join()}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 8),
                      const Text('Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      GitStatusList(statuses: gitState.statuses),
                      const SizedBox(height: 16),
                      const Text('Recent commits', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...gitState.commits.take(10).map((c) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.commit, size: 18, color: AppColors.textSecondary),
                            title: Text(c.message, style: const TextStyle(fontSize: 13)),
                            subtitle: Text('${c.author} · ${c.hash.substring(0, 7)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          )),
                    ],
                  ),
                ),
    );
  }
}

class _NotARepoView extends StatelessWidget {
  final VoidCallback onInit;
  const _NotARepoView({required this.onInit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.source_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('Not a Git repository'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onInit,
            icon: const Icon(Icons.add),
            label: const Text('Initialize Repository'),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final VoidCallback onStageAll;
  final VoidCallback onCommit;
  final VoidCallback onPush;
  final VoidCallback onPull;

  const _ActionsRow({
    required this.onStageAll,
    required this.onCommit,
    required this.onPush,
    required this.onPull,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(onPressed: onStageAll, icon: const Icon(Icons.add, size: 16), label: const Text('Stage all')),
        FilledButton.icon(onPressed: onCommit, icon: const Icon(Icons.check, size: 16), label: const Text('Commit')),
        OutlinedButton.icon(onPressed: onPush, icon: const Icon(Icons.upload, size: 16), label: const Text('Push')),
        OutlinedButton.icon(onPressed: onPull, icon: const Icon(Icons.download, size: 16), label: const Text('Pull')),
      ],
    );
  }
}
