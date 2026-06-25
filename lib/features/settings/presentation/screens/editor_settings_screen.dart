import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../editor/presentation/providers/editor_providers.dart';
import '../providers/settings_providers.dart';

/// "SETTINGS → Editor": font size, theme (dark only for now), tab size,
/// auto save.
class EditorSettingsScreen extends ConsumerWidget {
  const EditorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorSettings = ref.watch(editorSettingsProvider);
    final editorNotifier = ref.read(editorSettingsProvider.notifier);
    final appSettings = ref.watch(appSettingsProvider);
    final appNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Editor Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Font size'),
            subtitle: Slider(
              min: 10,
              max: 24,
              divisions: 14,
              value: editorSettings.fontSize,
              label: editorSettings.fontSize.toStringAsFixed(0),
              onChanged: (v) => editorNotifier.setFontSize(v),
            ),
          ),
          SwitchListTile(
            title: const Text('Word wrap'),
            value: editorSettings.wordWrap,
            onChanged: (_) => editorNotifier.toggleWordWrap(),
          ),
          ListTile(
            title: const Text('Tab size'),
            trailing: DropdownButton<int>(
              value: editorSettings.tabSize,
              items: const [2, 4, 8]
                  .map((s) => DropdownMenuItem(value: s, child: Text('$s spaces')))
                  .toList(),
              onChanged: (v) {
                if (v != null) editorNotifier.setTabSize(v);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Auto save'),
            subtitle: const Text('Automatically save files after edits'),
            value: appSettings.autoSave,
            onChanged: appNotifier.setAutoSave,
          ),
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Modern Dark (more themes coming soon)'),
            trailing: Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
    );
  }
}
