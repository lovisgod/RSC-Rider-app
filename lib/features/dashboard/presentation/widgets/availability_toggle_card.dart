import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';

class AvailabilityToggleCard extends StatelessWidget {
  const AvailabilityToggleCard({
    super.key,
    required this.isOnline,
    required this.isUpdating,
    required this.onChanged,
  });

  final bool isOnline;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.online : AppColors.offline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline,
              style: AppTextStyles.headlineSmall,
            ),
          ),
          if (isUpdating)
            const AppLoader(size: AppSpacing.iconMd)
          else
            Switch(
              value: isOnline,
              activeTrackColor: AppColors.online,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}
