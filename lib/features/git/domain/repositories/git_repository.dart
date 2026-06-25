import '../entities/git_branch.dart';
import '../entities/git_commit.dart';
import '../entities/git_status.dart';

/// Contract for the "GIT INTEGRATION" requirements. Implemented against
/// the system `git` CLI (see GitRepositoryImpl) so it works wherever a git
/// binary is reachable — desktop builds, CI, or an Android device with
/// git available via Termux. See docs/ARCHITECTURE.md for the on-device
/// git-binary caveat and the libgit2 upgrade path.
abstract class GitRepository {
  Future<bool> isGitAvailable();
  Future<bool> isRepository(String path);

  Future<void> init(String path);
  Future<void> clone(String url, String destPath, {void Function(String line)? onProgress});

  Future<List<GitFileStatus>> status(String path);
  Future<void> stage(String path, String filePath);
  Future<void> unstage(String path, String filePath);
  Future<void> commit(String path, String message);

  Future<void> push(String path, {String remote = 'origin', String? branch});
  Future<void> pull(String path, {String remote = 'origin', String? branch});

  Future<List<GitBranch>> listBranches(String path);
  Future<void> createBranch(String path, String name);
  Future<void> checkoutBranch(String path, String name);

  Future<List<GitCommit>> log(String path, {int limit = 30});
  Future<String> diff(String path, {String? filePath});

  /// Stores Git credentials (e.g. a personal access token) used for
  /// HTTPS push/pull, kept in SecureStorageService — never written to the
  /// repository's .git/config in plain text.
  Future<void> setCredentials({required String username, required String token});
}
