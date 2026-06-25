import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/secure_storage_service.dart';

/// Global, app-wide providers (singletons / cross-cutting services).
/// Feature-specific providers live inside each feature's
/// presentation/providers folder and depend on these where needed.

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});

/// Index of the active bottom navigation tab on mobile layout:
/// 0 = Editor, 1 = Terminal, 2 = Git, 3 = AI Assistant.
final activeBottomTabProvider = StateProvider<int>((ref) => 0);

/// Key for the *outer* mobile Scaffold (the one that owns the file-explorer
/// Drawer) so any nested screen's AppBar can open it via
/// `ref.read(homeScaffoldKeyProvider).currentState?.openDrawer()` — needed
/// because each tab (Editor/Terminal/Git/AI) renders its own inner
/// Scaffold, and Flutter only auto-wires a drawer button when the AppBar
/// and Drawer share the same Scaffold.
final homeScaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});
