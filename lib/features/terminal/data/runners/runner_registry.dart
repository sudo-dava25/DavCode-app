import '../../../../core/utils/file_utils.dart';
import 'dart_runner.dart';
import 'javascript_runner.dart';
import 'python_runner.dart';
import 'runner.dart';
import 'shell_runner.dart';

/// Central place where all available [Runner]s are registered. Adding a
/// new language: write a Runner subclass, add one line below — the
/// terminal UI and "run file" actions pick it up automatically.
class RunnerRegistry {
  RunnerRegistry._() {
    register(ShellRunner());
    register(DartRunner());
    register(PythonRunner());
    register(JavaScriptRunner());
  }

  static final RunnerRegistry instance = RunnerRegistry._();

  final Map<String, Runner> _byId = {};

  void register(Runner runner) => _byId[runner.id] = runner;

  Runner? byId(String id) => _byId[id];

  List<Runner> get all => _byId.values.toList();

  /// Picks the right runner for a file based on its extension.
  Runner? runnerForFile(String path) {
    final ext = FileUtils.extension(path).toLowerCase();
    for (final runner in _byId.values) {
      if (runner.extensions.contains(ext)) return runner;
    }
    return null;
  }
}
