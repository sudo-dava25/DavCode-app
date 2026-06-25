import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

/// "SETTINGS" hub — links into Editor / Terminal / AI sub-settings plus
/// general app info ("Project settings" lives on the project itself, see
/// FileExplorerScreen app bar; this screen covers app-wide preferences).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editor'),
            subtitle: const Text('Font size, theme, tab size, auto save'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/editor'),
          ),
          ListTile(
            leading: const Icon(Icons.terminal),
            title: const Text('Terminal'),
            subtitle: const Text('Shell preference, environment variables'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/terminal'),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Assistant'),
            subtitle: const Text('API key, provider, model selection'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/ai'),
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: AppConstants.appName,
            applicationVersion: AppConstants.appVersion,
            applicationLegalese: '© Dav Code',
          ),
        ],
      ),
    );
  }
}
