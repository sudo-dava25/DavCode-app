import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';

/// App-level settings that aren't owned by a single feature: auto-save,
/// terminal shell preference, and terminal environment variables.
/// Persisted via StorageService (Hive) so they survive app restarts.
class AppSettings {
  final bool autoSave;
  final String terminalShell;
  final Map<String, String> terminalEnv;

  const AppSettings({
    this.autoSave = true,
    this.terminalShell = '/system/bin/sh',
    this.terminalEnv = const {},
  });

  Map<String, dynamic> toMap() => {
        'autoSave': autoSave,
        'terminalShell': terminalShell,
        'terminalEnv': terminalEnv,
      };

  factory AppSettings.fromMap(Map map) => AppSettings(
        autoSave: map['autoSave'] as bool? ?? true,
        terminalShell: map['terminalShell'] as String? ?? '/system/bin/sh',
        terminalEnv: Map<String, String>.from(map['terminalEnv'] as Map? ?? {}),
      );

  AppSettings copyWith({bool? autoSave, String? terminalShell, Map<String, String>? terminalEnv}) {
    return AppSettings(
      autoSave: autoSave ?? this.autoSave,
      terminalShell: terminalShell ?? this.terminalShell,
      terminalEnv: terminalEnv ?? this.terminalEnv,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._storage) : super(_load(_storage));

  final StorageService _storage;
  static const _key = 'app_settings';

  static AppSettings _load(StorageService storage) {
    final raw = storage.getSetting<Map>(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromMap(raw);
  }

  Future<void> _persist() => _storage.setSetting(_key, state.toMap());

  Future<void> setAutoSave(bool value) async {
    state = state.copyWith(autoSave: value);
    await _persist();
  }

  Future<void> setTerminalShell(String shell) async {
    state = state.copyWith(terminalShell: shell);
    await _persist();
  }

  Future<void> setTerminalEnv(Map<String, String> env) async {
    state = state.copyWith(terminalEnv: env);
    await _persist();
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(StorageService.instance);
});
