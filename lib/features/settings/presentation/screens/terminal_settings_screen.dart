import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

/// "SETTINGS → Terminal": shell preference + environment variables.
class TerminalSettingsScreen extends ConsumerStatefulWidget {
  const TerminalSettingsScreen({super.key});

  @override
  ConsumerState<TerminalSettingsScreen> createState() => _TerminalSettingsScreenState();
}

class _TerminalSettingsScreenState extends ConsumerState<TerminalSettingsScreen> {
  late TextEditingController _shellController;
  late TextEditingController _envController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    _shellController = TextEditingController(text: settings.terminalShell);
    _envController = TextEditingController(
      text: settings.terminalEnv.entries.map((e) => '${e.key}=${e.value}').join('\n'),
    );
  }

  @override
  void dispose() {
    _shellController.dispose();
    _envController.dispose();
    super.dispose();
  }

  Map<String, String> _parseEnv(String text) {
    final map = <String, String>{};
    for (final line in text.split('\n')) {
      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      map[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              notifier.setTerminalShell(_shellController.text.trim());
              notifier.setTerminalEnv(_parseEnv(_envController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terminal settings saved')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Shell binary', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _shellController,
            decoration: const InputDecoration(hintText: '/system/bin/sh'),
          ),
          const SizedBox(height: 20),
          const Text('Environment variables (KEY=value per line)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _envController,
            maxLines: 6,
            decoration: const InputDecoration(hintText: 'PATH=/data/data/.../bin\nLANG=en_US.UTF-8'),
          ),
        ],
      ),
    );
  }
}
