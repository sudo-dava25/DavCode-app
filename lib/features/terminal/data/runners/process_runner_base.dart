import 'dart:convert';
import 'dart:io';
import 'runner.dart';

/// Shared process-spawning logic for runners that shell out to a real
/// binary (sh, dart, python3, node, ...). Concrete runners only need to
/// supply the executable + arguments; this base class handles streaming
/// stdout/stderr line-by-line and process lifecycle (start/stop).
abstract class ProcessRunnerBase implements Runner {
  Process? _process;

  /// Returns the executable to invoke and its arguments for running
  /// [filePathOrCommand]. Throwing a [RunnerUnavailableException] here
  /// signals "interpreter not found on this device" to the UI.
  (String executable, List<String> args) buildInvocation(String filePathOrCommand);

  @override
  Future<RunnerResult> run({
    required String filePathOrCommand,
    required String workingDirectory,
    required void Function(String line) onStdout,
    required void Function(String line) onStderr,
  }) async {
    final (executable, args) = buildInvocation(filePathOrCommand);

    try {
      _process = await Process.start(
        executable,
        args,
        workingDirectory: workingDirectory,
        runInShell: true,
      );
    } on ProcessException catch (e) {
      onStderr('Failed to start "$executable": ${e.message}');
      onStderr('This interpreter may not be installed on this device. '
          'See docs/ARCHITECTURE.md → Terminal & Code Runner for options '
          '(bundling a binary, or running via Termux).');
      return const RunnerResult(127);
    }

    final stdoutSub = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(onStdout);
    final stderrSub = _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(onStderr);

    final exitCode = await _process!.exitCode;
    await stdoutSub.cancel();
    await stderrSub.cancel();
    _process = null;
    return RunnerResult(exitCode);
  }

  @override
  Future<void> stop() async {
    _process?.kill(ProcessSignal.sigterm);
    _process = null;
  }
}
