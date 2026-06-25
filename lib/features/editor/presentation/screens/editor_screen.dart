import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/editor_providers.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/editor_tab_bar.dart';
import '../widgets/search_replace_bar.dart';

/// Main editor surface: tab bar + optional search bar + the active tab's
/// CodeEditorWidget. Used standalone on mobile (one of the bottom-nav
/// destinations) and as the center pane in the desktop 3-pane layout.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final tabsNotifier = ref.watch(editorTabsProvider.notifier);
    final tabs = ref.watch(editorTabsProvider);
    final settings = ref.watch(editorSettingsProvider);
    final activeController = tabsNotifier.activeController;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Editor'),
        leading: Responsive.isDesktop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref.read(homeScaffoldKeyProvider).currentState?.openDrawer(),
              ),
      ),
      body: Column(
        children: [
          EditorTabBar(
            tabs: tabs,
            activeTabId: tabsNotifier.activeTabId,
            onSelect: tabsNotifier.focusTab,
            onClose: tabsNotifier.closeTab,
          ),
          if (tabs.isNotEmpty)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tabsNotifier.activeTab?.filePath ?? '',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Search & Replace',
                    icon: const Icon(Icons.search, size: 18),
                    onPressed: () => setState(() => _showSearch = !_showSearch),
                  ),
                  IconButton(
                    tooltip: 'Word wrap: ${settings.wordWrap ? "on" : "off"}',
                    icon: Icon(Icons.wrap_text,
                        size: 18, color: settings.wordWrap ? AppColors.accent : AppColors.textMuted),
                    onPressed: () => ref.read(editorSettingsProvider.notifier).toggleWordWrap(),
                  ),
                  IconButton(
                    tooltip: 'Save',
                    icon: const Icon(Icons.save_outlined, size: 18),
                    onPressed: () => tabsNotifier.saveActiveTab(),
                  ),
                ],
              ),
            ),
          if (_showSearch && activeController != null)
            SearchReplaceBar(
              controller: activeController,
              onClose: () => setState(() => _showSearch = false),
            ),
          Expanded(
            child: tabs.isEmpty || activeController == null
                ? const _EmptyEditorState()
                : CodeEditorWidget(
                    key: ValueKey(tabsNotifier.activeTabId),
                    controller: activeController,
                    settings: settings,
                    readOnly: tabsNotifier.activeTab?.isReadOnlyLargeFile ?? false,
                    onChanged: () => tabsNotifier.markActiveTabDirty(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEditorState extends StatelessWidget {
  const _EmptyEditorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No file open', style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text(
            'Open a file from the Explorer to start editing',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
