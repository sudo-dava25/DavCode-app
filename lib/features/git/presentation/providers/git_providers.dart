import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/git_repository_impl.dart';
import '../../domain/entities/git_branch.dart';
import '../../domain/entities/git_commit.dart';
import '../../domain/entities/git_status.dart';
import '../../domain/repositories/git_repository.dart';

final gitRepositoryProvider = Provider<GitRepository>((ref) => GitRepositoryImpl());

class GitState {
  final bool loading;
  final bool isRepo;
  final List<GitFileStatus> statuses;
  final List<GitBranch> branches;
  final List<GitCommit> commits;
  final String? error;

  const GitState({
    this.loading = false,
    this.isRepo = false,
    this.statuses = const [],
    this.branches = const [],
    this.commits = const [],
    this.error,
  });

  GitState copyWith({
    bool? loading,
    bool? isRepo,
    List<GitFileStatus>? statuses,
    List<GitBranch>? branches,
    List<GitCommit>? commits,
    String? error,
  }) {
    return GitState(
      loading: loading ?? this.loading,
      isRepo: isRepo ?? this.isRepo,
      statuses: statuses ?? this.statuses,
      branches: branches ?? this.branches,
      commits: commits ?? this.commits,
      error: error,
    );
  }
}

/// Drives the Git screen: refreshes status/branches/log for the current
/// project and exposes init/commit/push/pull/branch actions.
class GitNotifier extends StateNotifier<GitState> {
  GitNotifier(this._repo) : super(const GitState());

  final GitRepository _repo;
  String? _projectPath;

  Future<void> bind(String projectPath) async {
    _projectPath = projectPath;
    await refresh();
  }

  Future<void> refresh() async {
    final path = _projectPath;
    if (path == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final isRepo = await _repo.isRepository(path);
      if (!isRepo) {
        state = const GitState(isRepo: false);
        return;
      }
      final statuses = await _repo.status(path);
      final branches = await _repo.listBranches(path);
      final commits = await _repo.log(path);
      state = GitState(isRepo: true, statuses: statuses, branches: branches, commits: commits);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> initRepo() async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.init(path));
  }

  Future<void> stageAll() async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() async {
      for (final s in state.statuses) {
        await _repo.stage(path, s.path);
      }
    });
  }

  Future<void> commit(String message) async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.commit(path, message));
  }

  Future<void> push() async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.push(path));
  }

  Future<void> pull() async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.pull(path));
  }

  Future<void> createBranch(String name) async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.createBranch(path, name));
  }

  Future<void> checkoutBranch(String name) async {
    final path = _projectPath;
    if (path == null) return;
    await _guard(() => _repo.checkoutBranch(path, name));
  }

  Future<void> _guard(Future<void> Function() action) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await action();
      await refresh();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final gitNotifierProvider = StateNotifierProvider<GitNotifier, GitState>((ref) {
  return GitNotifier(ref.watch(gitRepositoryProvider));
});
