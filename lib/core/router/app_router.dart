import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/ai_settings_screen.dart';
import '../../features/settings/presentation/screens/editor_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terminal_settings_screen.dart';

/// App-wide navigation graph. Kept flat and small on purpose: the main
/// IDE surfaces (Explorer/Editor/Terminal/Git/AI) are NOT separate routes
/// — they're tabs/panes inside [HomeScreen] (see Responsive layout) so
/// switching between them never triggers a route transition. Only
/// Settings gets real routes, since it's a stack of drill-down pages.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(path: 'editor', builder: (context, state) => const EditorSettingsScreen()),
        GoRoute(path: 'terminal', builder: (context, state) => const TerminalSettingsScreen()),
        GoRoute(path: 'ai', builder: (context, state) => const AiSettingsScreen()),
      ],
    ),
  ],
);
