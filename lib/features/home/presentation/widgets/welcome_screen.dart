import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Small branded header used at the top of the mobile drawer and as a
/// placeholder panel on desktop before a project is open.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      color: AppColors.surface,
      child: const Row(
        children: [
          Icon(Icons.code, color: AppColors.accent, size: 28),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('v${AppConstants.appVersion}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
