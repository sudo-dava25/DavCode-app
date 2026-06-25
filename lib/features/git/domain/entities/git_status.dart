enum GitFileState { added, modified, deleted, untracked, renamed, conflicted }

/// One entry from `git status --porcelain`, powering "Git status" /
/// "View changes".
class GitFileStatus {
  final String path;
  final GitFileState state;
  final bool staged;

  const GitFileStatus({required this.path, required this.state, required this.staged});

  static GitFileState stateFromCode(String code) {
    switch (code.trim()) {
      case 'A':
        return GitFileState.added;
      case 'M':
        return GitFileState.modified;
      case 'D':
        return GitFileState.deleted;
      case 'R':
        return GitFileState.renamed;
      case 'U':
      case 'UU':
        return GitFileState.conflicted;
      case '?':
      case '??':
        return GitFileState.untracked;
      default:
        return GitFileState.modified;
    }
  }
}
