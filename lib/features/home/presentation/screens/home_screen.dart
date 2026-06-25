import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../ai/presentation/screens/ai_chat_screen.dart';
import '../../../editor/presentation/providers/editor_providers.dart';
import '../../../editor/presentation/screens/editor_screen.dart';
import '../../../file_manager/presentation/providers/file_explorer_providers.dart';
import '../../../file_manager/presentation/screens/file_explorer_screen.dart';
import '../../../git/presentation/screens/git_screen.dart';
import '../../../terminal/presentation/providers/terminal_providers.dart';
import '../../../terminal/presentation/screens/terminal_screen.dart';
import '../widgets/welcome_screen.dart';

/// App shell: picks between the desktop 3-pane layout
/// ("Explorer | Editor | AI Assistant", terminal docked at bottom) and the
/// mobile layout (bottom navigation + drawer file explorer + FAB), per the
/// "UI DAN UX DESIGN" requirement.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Responsive.isDesktop(context)) {
      return const _DesktopLayout();
    }
    return const _MobileLayout();
  }
}

// ---------------------------------------------------------------------------
// Mobile layout: bottom nav (Editor / Terminal / Git / AI) + drawer
// (File Explorer) + FAB (Run active file).
// ---------------------------------------------------------------------------
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout();

  Future<void> _runActiveFile(WidgetRef ref) async {
    final tabsNotifier = ref.read(editorTabsProvider.notifier);
    final tab = tabsNotifier.activeTab;
    final workspace = ref.read(currentWorkspaceProvider);
    if (tab == null) return;

    await tabsNotifier.saveActiveTab();
    final terminalNotifier = ref.read(terminalSessionsProvider.notifier);
    final session = terminalNotifier.activeSession;
    if (session == null) return;

    ref.read(activeBottomTabProvider.notifier).state = 1; // jump to Terminal tab
    await terminalNotifier.runFile(session.id, tab.filePath, workspace?.rootPath ?? '/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(activeBottomTabProvider);
    final tabs = ref.watch(editorTabsProvider);
    final hasActiveFile = tabs.isNotEmpty;

    const pages = [
      EditorScreen(),
      TerminalScreen(),
      GitScreen(),
      AiChatScreen(),
    ];

    return Scaffold(
      key: ref.watch(homeScaffoldKeyProvider),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        child: Column(
          children: [
            const WelcomeHeader(),
            const Expanded(child: FileExplorerScreen()),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: activeIndex, children: pages),
      floatingActionButton: hasActiveFile && activeIndex == 0
          ? FloatingActionButton(
              tooltip: 'Run',
              onPressed: () => _runActiveFile(ref),
              child: const Icon(Icons.play_arrow),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (i) => ref.read(activeBottomTabProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: 'Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'Terminal'),
          BottomNavigationBarItem(icon: Icon(Icons.source_outlined), label: 'Git'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop / tablet layout: Explorer (or Git) | Editor + Terminal | AI.
// ---------------------------------------------------------------------------
class _DesktopLayout extends ConsumerStatefulWidget {
  const _DesktopLayout();

  @override
  ConsumerState<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends ConsumerState<_DesktopLayout> {
  int _leftPaneIndex = 0; // 0 = Explorer, 1 = Git
  bool _showTerminal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Icon rail to switch the left panel between Explorer and Git.
          NavigationRail(
            selectedIndex: _leftPaneIndex,
            onDestinationSelected: (i) => setState(() => _leftPaneIndex = i),
            backgroundColor: AppColors.surface,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.code, color: AppColors.accent),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/settings'),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.folder_outlined), label: Text('Explorer')),
              NavigationRailDestination(icon: Icon(Icons.source_outlined), label: Text('Git')),
            ],
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          // Left pane
          SizedBox(
            width: 300,
            child: _leftPaneIndex == 0 ? const FileExplorerScreen() : const GitScreen(),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          // Center: Editor on top, Terminal docked at the bottom.
          Expanded(
            child: Column(
              children: [
                Expanded(flex: _showTerminal ? 7 : 10, child: const EditorScreen()),
                if (_showTerminal) const Divider(height: 1, color: AppColors.border),
                if (_showTerminal) const Expanded(flex: 3, child: TerminalScreen()),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          // Right pane: AI Assistant.
          const SizedBox(width: 360, child: AiChatScreen()),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: _showTerminal ? 'Hide terminal' : 'Show terminal',
        onPressed: () => setState(() => _showTerminal = !_showTerminal),
        child: Icon(_showTerminal ? Icons.keyboard_arrow_down : Icons.terminal),
      ),
    );
  }
}
