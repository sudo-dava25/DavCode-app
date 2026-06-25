/// App-wide constants for Dav Code.
class AppConstants {
  AppConstants._();

  static const String appName = 'Dav Code';
  static const String packageName = 'com.davcode.dev';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String boxRecentProjects = 'recent_projects';
  static const String boxWorkspaces = 'workspaces';
  static const String boxSettings = 'settings';
  static const String boxEditorState = 'editor_state';

  // Secure storage keys
  static const String keyOpenAiApiKey = 'ai_openai_api_key';
  static const String keyCustomEndpointKey = 'ai_custom_endpoint_key';
  static const String keyGitToken = 'git_credential_token';

  // Defaults
  static const int defaultTabSize = 4;
  static const double defaultFontSize = 14.0;
  static const int maxRecentProjects = 15;
  static const int maxTerminalHistory = 200;

  // Large file handling threshold (bytes) — files above this open in a
  // read-only / lazily-paginated viewer instead of the full editor.
  static const int largeFileThresholdBytes = 2 * 1024 * 1024; // 2 MB
}
