import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/runners/runner_registry.dart';
import '../../domain/entities/terminal_line.dart';
import '../../domain/entities/terminal_session.dart';

final runnerRegistryProvider = Provider<RunnerRegistry>((ref) => RunnerRegistry.instance);

/// Manages multiple terminal tabs ("Multiple terminal session"), command
/// history, running state, and dispatches commands to the right Runner.
class TerminalSessionsNotifier extends StateNotifier<List<TerminalSession>> {
  TerminalSessionsNotifier(this._registry) : super([]) {
    addSession(workingDirectory: '/');
  }

  final RunnerRegistry _registry;
  final _uuid = const Uuid();
  String? activeSessionId;

  TerminalSession? get activeSession =>
      state.where((s) => s.id == activeSessionId).cast<TerminalSession?>().firstOrNull;

  void addSession({required String workingDirectory}) {
    final session = TerminalSession(
      id: _uuid.v4(),
      name: 'Terminal ${state.length + 1}',
      workingDirectory: workingDirectory,
    );
    state = [...state, session];
    activeSessionId = session.id;
  }

  void closeSession(String id) {
    state = state.where((s) => s.id != id).toList();
    if (activeSessionId == id) {
      activeSessionId = state.isNotEmpty ? state.last.id : null;
    }
  }

  void focusSession(String id) {
    activeSessionId = id;
    state = [...state];
  }

  void clear(String sessionId) {
    final session = state.firstWhere((s) => s.id == sessionId);
    session.output.clear();
    state = [...state];
  }

  Future<void> execute(String sessionId, String command) async {
    final session = state.firstWhere((s) => s.id == sessionId);
    if (command.trim().isEmpty) return;

    session.commandHistory.add(command);
    if (session.commandHistory.length > AppConstants.maxTerminalHistory) {
      session.commandHistory.removeAt(0);
    }
    session.output.add(TerminalLine(text: '\$ $command', type: TerminalLineType.input));
    session.isRunning = true;
    state = [...state];

    final runner = _registry.byId('shell')!;
    await runner.run(
      filePathOrCommand: command,
      workingDirectory: session.workingDirectory,
      onStdout: (line) {
        session.output.add(TerminalLine(text: line, type: TerminalLineType.stdout));
        state = [...state];
      },
      onStderr: (line) {
        session.output.add(TerminalLine(text: line, type: TerminalLineType.stderr));
        state = [...state];
      },
    );

    session.isRunning = false;
    state = [...state];
  }

  /// Runs a specific file with whichever Runner matches its extension —
  /// this is what the editor's "Run" action calls.
  Future<void> runFile(String sessionId, String filePath, String workingDirectory) async {
    final session = state.firstWhere((s) => s.id == sessionId);
    final runner = _registry.runnerForFile(filePath);
    if (runner == null) {
      session.output.add(TerminalLine(
        text: 'No runner registered for this file type.',
        type: TerminalLineType.system,
      ));
      state = [...state];
      return;
    }

    session.output.add(TerminalLine(
      text: '\$ ${runner.displayName}: $filePath',
      type: TerminalLineType.input,
    ));
    session.isRunning = true;
    state = [...state];

    final result = await runner.run(
      filePathOrCommand: filePath,
      workingDirectory: workingDirectory,
      onStdout: (line) {
        session.output.add(TerminalLine(text: line, type: TerminalLineType.stdout));
        state = [...state];
      },
      onStderr: (line) {
        session.output.add(TerminalLine(text: line, type: TerminalLineType.stderr));
        state = [...state];
      },
    );

    session.output.add(TerminalLine(
      text: 'Process exited with code ${result.exitCode}',
      type: TerminalLineType.system,
    ));
    session.isRunning = false;
    state = [...state];
  }

  Future<void> stop(String sessionId) async {
    for (final runner in _registry.all) {
      await runner.stop();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

final terminalSessionsProvider =
    StateNotifierProvider<TerminalSessionsNotifier, List<TerminalSession>>((ref) {
  return TerminalSessionsNotifier(ref.watch(runnerRegistryProvider));
});
