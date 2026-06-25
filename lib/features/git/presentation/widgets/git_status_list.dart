import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/git_status.dart';

Color colorForState(GitFileState state) {
  switch (state) {
    case GitFileState.added:
      return AppColors.gitAdded;
    case GitFileState.modified:
      return AppColors.gitModified;
    case GitFileState.deleted:
      return AppColors.gitDeleted;
    case GitFileState.untracked:
      return AppColors.gitUntracked;
    case GitFileState.renamed:
      return AppColors.info;
    case GitFileState.conflicted:
      return AppColors.error;
  }
}

String labelForState(GitFileState state) {
  switch (state) {
    case GitFileState.added:
      return 'A';
    case GitFileState.modified:
      return 'M';
    case GitFileState.deleted:
      return 'D';
    case GitFileState.untracked:
      return 'U';
    case GitFileState.renamed:
      return 'R';
    case GitFileState.conflicted:
      return '!';
  }
}

/// Lists changed files with their status badge ("Git status" / "View
/// changes" requirement).
class GitStatusList extends StatelessWidget {
  final List<GitFileStatus> statuses;

  const GitStatusList({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No changes', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final s = statuses[index];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 11,
            backgroundColor: colorForState(s.state).withValues(alpha: 0.15),
            child: Text(labelForState(s.state),
                style: TextStyle(fontSize: 11, color: colorForState(s.state), fontWeight: FontWeight.bold)),
          ),
          title: Text(s.path, style: const TextStyle(fontSize: 13)),
          trailing: s.staged
              ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
              : const Icon(Icons.radio_button_unchecked, size: 16, color: AppColors.textMuted),
        );
      },
    );
  }
}
