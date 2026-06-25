import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/file_node.dart';

IconData iconForFile(String name) {
  final ext = FileUtils.extension(name).toLowerCase();
  switch (ext) {
    case '.dart':
      return Icons.flutter_dash;
    case '.kt':
    case '.kts':
    case '.java':
      return Icons.coffee;
    case '.js':
    case '.ts':
    case '.tsx':
      return Icons.javascript;
    case '.py':
      return Icons.code;
    case '.json':
    case '.yaml':
    case '.yml':
      return Icons.data_object;
    case '.html':
    case '.xml':
      return Icons.html;
    case '.css':
      return Icons.css;
    case '.md':
      return Icons.description_outlined;
    case '.sh':
    case '.bash':
      return Icons.terminal;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

/// One row in the file tree: a file or a folder, with context menu actions
/// for rename / delete / copy / move ("FILE MANAGER" requirements).
class FileTreeItem extends StatelessWidget {
  final FileNode node;
  final int depth;
  final bool isExpanded;
  final VoidCallback onTap;
  final void Function(String action) onAction;

  const FileTreeItem({
    super.key,
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Padding(
        padding: EdgeInsets.only(left: 12.0 * depth + 8, top: 7, bottom: 7, right: 8),
        child: Row(
          children: [
            if (node.isDirectory)
              Icon(isExpanded ? Icons.folder_open : Icons.folder,
                  size: 17, color: AppColors.accent)
            else
              Icon(iconForFile(node.name), size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.name,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => _showContextMenu(context),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert, size: 16, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            _action(ctx, Icons.drive_file_rename_outline, 'Rename', 'rename'),
            _action(ctx, Icons.copy_outlined, 'Copy', 'copy'),
            _action(ctx, Icons.drive_file_move_outline, 'Move', 'move'),
            _action(ctx, Icons.delete_outline, 'Delete', 'delete', color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext ctx, IconData icon, String label, String action, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: color ?? AppColors.textPrimary)),
      onTap: () {
        Navigator.pop(ctx);
        onAction(action);
      },
    );
  }
}
