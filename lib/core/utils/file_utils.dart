import 'dart:io';

/// Small filesystem helpers shared across file_manager / editor / git.
class FileUtils {
  FileUtils._();

  static String fileName(String path) => path.split(Platform.pathSeparator).last;

  static String extension(String path) {
    final name = fileName(path);
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return '';
    return name.substring(dot);
  }

  static String parentDir(String path) {
    final sep = Platform.pathSeparator;
    final idx = path.lastIndexOf(sep);
    if (idx <= 0) return sep;
    return path.substring(0, idx);
  }

  static String humanReadableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Joins path segments using the platform separator, collapsing
  /// duplicate separators.
  static String join(String base, String child) {
    if (base.endsWith(Platform.pathSeparator)) {
      return '$base$child';
    }
    return '$base${Platform.pathSeparator}$child';
  }

  static bool isLikelyTextFile(String path) {
    const binaryExt = {
      '.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.ico',
      '.apk', '.aab', '.so', '.jar', '.zip', '.gz', '.tar',
      '.ttf', '.otf', '.mp3', '.mp4', '.mov', '.pdf', '.exe',
    };
    return !binaryExt.contains(extension(path).toLowerCase());
  }
}
