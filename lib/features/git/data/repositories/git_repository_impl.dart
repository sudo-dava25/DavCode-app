import 'dart:convert';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/git_branch.dart';
import '../../domain/entities/git_commit.dart';
import '../../domain/entities/git_status.dart';
import '../../domain/repositories/git_repository.dart';

class GitCommandException implements Exception {
  final String message;
  GitCommandException(this.message);
  @override
  String toString() => message;
}

/// Shells out to the system `git` binary. Every public method is a thin,
/// readable wrapper around one or two `git` invocations — this keeps the
/// mapping between a UI action and the underlying git command obvious and
/// easy to extend (e.g. adding `stash`, `rebase`, etc. later).
class GitRepositoryImpl implements GitRepository {
  final SecureStorageService _secureStorage;

  GitRepositoryImpl({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService.instance;

  Future<ProcessResult> _run(List<String> args, {String? workingDirectory}) async {
    try {
      return await Process.run('git', args, workingDirectory: workingDirectory);
    } on ProcessException catch (e) {
      throw GitCommandException(
        'git is not available on this device (${e.message}). '
        'Install git (e.g. via Termux) or bundle a portable git binary — '
        'see docs/ARCHITECTURE.md.',
      );
    }
  }

  @override
  Future<bool> isGitAvailable() async {
    try {
      final result = await Process.run('git', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isRepository(String path) async {
    final result = await _run(['rev-parse', '--is-inside-work-tree'], workingDirectory: path);
    return result.exitCode == 0;
  }

  @override
  Future<void> init(String path) async {
    final result = await _run(['init'], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<void> clone(String url, String destPath, {void Function(String line)? onProgress}) async {
    Process process;
    try {
      process = await Process.start('git', ['clone', '--progress', url, destPath]);
    } on ProcessException catch (e) {
      throw GitCommandException('git is not available on this device (${e.message}).');
    }
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      onProgress?.call(line); // git writes clone progress to stderr
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw GitCommandException('git clone failed with exit code $exitCode');
    }
  }

  @override
  Future<List<GitFileStatus>> status(String path) async {
    final result = await _run(['status', '--porcelain=v1'], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());

    final lines = (result.stdout as String).split('\n').where((l) => l.trim().isNotEmpty);
    final statuses = <GitFileStatus>[];
    for (final line in lines) {
      if (line.length < 4) continue;
      final indexCode = line[0];
      final workTreeCode = line[1];
      final filePath = line.substring(3).trim();
      final staged = indexCode != ' ' && indexCode != '?';
      final code = indexCode != ' ' ? indexCode : workTreeCode;
      statuses.add(GitFileStatus(
        path: filePath,
        state: GitFileStatus.stateFromCode(code),
        staged: staged,
      ));
    }
    return statuses;
  }

  @override
  Future<void> stage(String path, String filePath) async {
    final result = await _run(['add', filePath], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<void> unstage(String path, String filePath) async {
    final result = await _run(['restore', '--staged', filePath], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<void> commit(String path, String message) async {
    final result = await _run(['commit', '-m', message], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<void> push(String path, {String remote = 'origin', String? branch}) async {
    await _withAuthenticatedRemote(path, remote, () async {
      final args = ['push', remote, if (branch != null) branch];
      final result = await _run(args, workingDirectory: path);
      if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
    });
  }

  @override
  Future<void> pull(String path, {String remote = 'origin', String? branch}) async {
    await _withAuthenticatedRemote(path, remote, () async {
      final args = ['pull', remote, if (branch != null) branch];
      final result = await _run(args, workingDirectory: path);
      if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
    });
  }

  @override
  Future<List<GitBranch>> listBranches(String path) async {
    final result = await _run(['branch', '--all'], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());

    final lines = (result.stdout as String).split('\n').where((l) => l.trim().isNotEmpty);
    return lines.map((line) {
      final isCurrent = line.startsWith('*');
      final name = line.replaceFirst('*', '').trim();
      return GitBranch(
        name: name,
        isCurrent: isCurrent,
        isRemote: name.startsWith('remotes/'),
      );
    }).toList();
  }

  @override
  Future<void> createBranch(String path, String name) async {
    final result = await _run(['branch', name], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<void> checkoutBranch(String path, String name) async {
    final result = await _run(['checkout', name], workingDirectory: path);
    if (result.exitCode != 0) throw GitCommandException(result.stderr.toString());
  }

  @override
  Future<List<GitCommit>> log(String path, {int limit = 30}) async {
    final result = await _run(
      ['log', '-n', '$limit', '--pretty=format:%H|%an|%ad|%s', '--date=iso'],
      workingDirectory: path,
    );
    if (result.exitCode != 0) return [];

    final lines = (result.stdout as String).split('\n').where((l) => l.trim().isNotEmpty);
    return lines.map((line) {
      final parts = line.split('|');
      return GitCommit(
        hash: parts[0],
        author: parts.length > 1 ? parts[1] : '',
        date: parts.length > 2 ? DateTime.tryParse(parts[2]) ?? DateTime.now() : DateTime.now(),
        message: parts.length > 3 ? parts.sublist(3).join('|') : '',
      );
    }).toList();
  }

  @override
  Future<String> diff(String path, {String? filePath}) async {
    final args = ['diff', if (filePath != null) filePath];
    final result = await _run(args, workingDirectory: path);
    return result.stdout as String;
  }

  @override
  Future<void> setCredentials({required String username, required String token}) async {
    await _secureStorage.write('git_username', username);
    await _secureStorage.write(AppConstants.keyGitToken, token);
  }

  /// Temporarily rewrites [remote]'s URL to embed stored credentials for
  /// the duration of [action], then restores the original URL — avoids
  /// persisting the token inside .git/config.
  Future<void> _withAuthenticatedRemote(String path, String remote, Future<void> Function() action) async {
    final username = await _secureStorage.read('git_username');
    final token = await _secureStorage.read(AppConstants.keyGitToken);
    if (username == null || token == null) {
      await action();
      return;
    }

    final originalUrlResult = await _run(['remote', 'get-url', remote], workingDirectory: path);
    final originalUrl = (originalUrlResult.stdout as String).trim();
    if (originalUrl.isEmpty || !originalUrl.startsWith('http')) {
      await action();
      return;
    }

    final uri = Uri.parse(originalUrl);
    final authedUrl = uri.replace(userInfo: '$username:$token').toString();

    await _run(['remote', 'set-url', remote, authedUrl], workingDirectory: path);
    try {
      await action();
    } finally {
      await _run(['remote', 'set-url', remote, originalUrl], workingDirectory: path);
    }
  }
}
