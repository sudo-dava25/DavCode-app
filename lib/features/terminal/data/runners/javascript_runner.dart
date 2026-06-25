import 'process_runner_base.dart';

/// Executes a JavaScript file via Node.js. See DartRunner's doc comment
/// for the on-device-interpreter caveat — same applies here.
class JavaScriptRunner extends ProcessRunnerBase {
  @override
  String get id => 'javascript';

  @override
  String get displayName => 'JavaScript (Node)';

  @override
  List<String> get extensions => ['.js', '.mjs', '.cjs'];

  @override
  (String, List<String>) buildInvocation(String filePathOrCommand) {
    return ('node', [filePathOrCommand]);
  }
}
