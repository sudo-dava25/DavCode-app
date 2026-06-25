import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/editor_tab.dart';

/// Horizontal, scrollable strip of open file tabs ("Multiple file tabs").
class EditorTabBar extends StatelessWidget {
  final List<EditorTab> tabs;
  final String? activeTabId;
  final void Function(String tabId) onSelect;
  final void Function(String tabId) onClose;

  const EditorTabBar({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 40,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = tab.id == activeTabId;
          return InkWell(
            onTap: () => onSelect(tab.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.surfaceElevated : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.accent : Colors.transparent,
                    width: 2,
                  ),
                  right: const BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file_outlined,
                      size: 14,
                      color: isActive ? AppColors.accent : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    tab.fileName,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (tab.isDirty)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                    )
                  else
                    InkWell(
                      onTap: () => onClose(tab.id),
                      child: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
