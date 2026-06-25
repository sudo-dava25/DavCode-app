import 'dart:async';

/// Result of one process executed by a [Runner].
class RunnerResult {
  final int exitCode;
  const RunnerResult(this.exitCode);
}

/// Base contract every language runner implements. Adding support for a
/// new language is exactly: implement this class, register it in
/// [RunnerRegistry] — nothing else in the terminal UI needs to change,
/// satisfying the "modular runner system" requirement.
abstract class Runner {
  /// Short identifier, e.g. 'dart', 'python', 'javascript', 'shell'.
  String get id;

  /// Human-readable name shown in the runner picker.
  String get displayName;

  /// File extensions this runner can execute directly (e.g. ['.py']).
  List<String> get extensions;

  /// Runs [filePathOrCommand] inside [workingDirectory], streaming output
  /// lines as they arrive via [onStdout]/[onStderr], and returns the exit
  /// code once the process completes (or a non-zero code immediately if the
  /// required interpreter/binary isn't available on this device).
  Future<RunnerResult> run({
    required String filePathOrCommand,
    required String workingDirectory,
    required void Function(String line) onStdout,
    required void Function(String line) onStderr,
  });

  /// Attempts to stop a currently running process started by this runner.
  Future<void> stop();
}
