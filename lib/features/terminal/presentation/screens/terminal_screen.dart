import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/terminal_providers.dart';
import '../widgets/terminal_view.dart';

/// "TERMINAL DAN CODE RUNNER" screen — tabs across the top for multiple
/// sessions, clear/new-session actions, and the active session's console.
class TerminalScreen extends ConsumerWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsNotifier = ref.watch(terminalSessionsProvider.notifier);
    final sessions = ref.watch(terminalSessionsProvider);
    final active = sessionsNotifier.activeSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        leading: Responsive.isDesktop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref.read(homeScaffoldKeyProvider).currentState?.openDrawer(),
              ),
        actions: [
          IconButton(
            tooltip: 'New session',
            icon: const Icon(Icons.add),
            onPressed: () => sessionsNotifier.addSession(workingDirectory: active?.workingDirectory ?? '/'),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: active == null ? null : () => sessionsNotifier.clear(active.id),
          ),
          IconButton(
            tooltip: 'Stop',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: active == null ? null : () => sessionsNotifier.stop(active.id),
          ),
        ],
      ),
      body: Column(
        children: [
          if (sessions.length > 1)
            Container(
              height: 36,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final isActive = s.id == sessionsNotifier.activeSessionId;
                  return InkWell(
                    onTap: () => sessionsNotifier.focusSession(s.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? AppColors.accent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.name,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary)),
                          if (sessions.length > 1) ...[
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => sessionsNotifier.closeSession(s.id),
                              child: const Icon(Icons.close, size: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: active == null
                ? const Center(child: Text('No terminal session', style: TextStyle(color: AppColors.textSecondary)))
                : TerminalView(
                    key: ValueKey(active.id),
                    session: active,
                    onSubmit: (cmd) => sessionsNotifier.execute(active.id, cmd),
                  ),
          ),
        ],
      ),
    );
  }
}
