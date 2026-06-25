import 'process_runner_base.dart';

/// Executes a Python file via `python3`. See DartRunner's doc comment for
/// the on-device-interpreter caveat — same applies here.
class PythonRunner extends ProcessRunnerBase {
  @override
  String get id => 'python';

  @override
  String get displayName => 'Python';

  @override
  List<String> get extensions => ['.py'];

  @override
  (String, List<String>) buildInvocation(String filePathOrCommand) {
    return ('python3', [filePathOrCommand]);
  }
}
