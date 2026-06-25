import 'dart:io';
import 'process_runner_base.dart';

/// Executes raw shell commands ("Shell command" requirement). Uses
/// /system/bin/sh on Android, /bin/sh elsewhere.
class ShellRunner extends ProcessRunnerBase {
  @override
  String get id => 'shell';

  @override
  String get displayName => 'Shell';

  @override
  List<String> get extensions => ['.sh', '.bash'];

  @override
  (String, List<String>) buildInvocation(String filePathOrCommand) {
    final shell = Platform.isAndroid ? '/system/bin/sh' : '/bin/sh';
    return (shell, ['-c', filePathOrCommand]);
  }
}
