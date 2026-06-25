import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Wraps Hive (structured data: recent projects, workspaces, editor state)
/// and SharedPreferences (simple flags/settings) behind one service so the
/// rest of the app never talks to a storage backend directly. This makes it
/// easy to swap storage implementations later without touching features.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late Box _recentProjectsBox;
  late Box _workspacesBox;
  late Box _settingsBox;
  late Box _editorStateBox;
  SharedPreferences? _prefs;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _recentProjectsBox = await Hive.openBox(AppConstants.boxRecentProjects);
    _workspacesBox = await Hive.openBox(AppConstants.boxWorkspaces);
    _settingsBox = await Hive.openBox(AppConstants.boxSettings);
    _editorStateBox = await Hive.openBox(AppConstants.boxEditorState);
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- Recent projects -----------------------------------------------
  Box get recentProjects => _recentProjectsBox;

  // --- Workspaces -------------------------------------------------------
  Box get workspaces => _workspacesBox;

  // --- Editor state (open tabs, cursor position, etc.) ------------------
  Box get editorState => _editorStateBox;

  // --- Generic key/value settings ---------------------------------------
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService.init() must be called before use.');
    }
    return _prefs!;
  }
}
