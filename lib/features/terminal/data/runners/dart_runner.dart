import 'process_runner_base.dart';

/// Executes a Dart file via `dart run`. Requires the Dart SDK to be
/// reachable on PATH — true when Dav Code itself is run via `flutter run`
/// from a dev machine, or on a device with a Dart SDK installed (e.g. via
/// Termux). On a stock Android device this will surface a clear
/// "interpreter not found" message instead of crashing, by design.
class DartRunner extends ProcessRunnerBase {
  @override
  String get id => 'dart';

  @override
  String get displayName => 'Dart';

  @override
  List<String> get extensions => ['.dart'];

  @override
  (String, List<String>) buildInvocation(String filePathOrCommand) {
    return ('dart', ['run', filePathOrCommand]);
  }
}
