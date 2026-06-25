import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Centralizes Android storage-permission handling so the file explorer
/// never has to ask: which permission, on which Android version?
/// ("Android permission handling" requirement.)
class PermissionService {
  /// Requests whatever storage permission is appropriate for the running
  /// Android version: scoped READ/WRITE on Android ≤12, or
  /// MANAGE_EXTERNAL_STORAGE on Android 13+ for full project-folder access
  /// (needed because IDE-style apps must read/write arbitrary project
  /// directories, not just their own sandbox).
  Future<bool> requestStorageAccess() async {
    if (!Platform.isAndroid) return true;

    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) return true;

    final requested = await Permission.manageExternalStorage.request();
    if (requested.isGranted) return true;

    // Fallback for devices/policies where MANAGE_EXTERNAL_STORAGE prompts
    // are restricted — try classic storage permission instead.
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  Future<bool> hasStorageAccess() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    return Permission.storage.isGranted;
  }

  Future<void> openSettingsIfPermanentlyDenied() async {
    if (await Permission.manageExternalStorage.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
