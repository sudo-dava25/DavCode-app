import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive-backed storage (recent projects, workspaces, editor
  // state, settings) before the app starts so every screen can rely on it
  // being ready synchronously.
  await StorageService.instance.init();

  runApp(const ProviderScope(child: DavCodeApp()));
}
