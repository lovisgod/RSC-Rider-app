import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

enum OrderStatus { pending, inProgress, completed, cancelled }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color get _bg => switch (status) {
        OrderStatus.pending => AppColors.warningLight,
        OrderStatus.inProgress => AppColors.infoLight,
        OrderStatus.completed => AppColors.successLight,
        OrderStatus.cancelled => AppColors.errorLight,
      };

  Color get _fg => switch (status) {
        OrderStatus.pending => AppColors.warning,
        OrderStatus.inProgress => AppColors.info,
        OrderStatus.completed => AppColors.success,
        OrderStatus.cancelled => AppColors.error,
      };

  String get _label => switch (status) {
        OrderStatus.pending => AppStrings.statusPending,
        OrderStatus.inProgress => AppStrings.statusInProgress,
        OrderStatus.completed => AppStrings.statusCompleted,
        OrderStatus.cancelled => AppStrings.statusCancelled,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          _label,
          style: AppTextStyles.statusLabel.copyWith(color: _fg),
        ),
      );
}
