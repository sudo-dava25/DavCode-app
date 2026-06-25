import 'terminal_line.dart';

/// One terminal tab/session ("Multiple terminal session" requirement).
class TerminalSession {
  final String id;
  String name;
  String workingDirectory;
  final List<TerminalLine> output = [];
  final List<String> commandHistory = [];
  bool isRunning = false;

  TerminalSession({
    required this.id,
    required this.name,
    required this.workingDirectory,
  });
}
