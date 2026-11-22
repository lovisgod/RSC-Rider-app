import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/features/history/domain/entities/delivery_history_entity.dart';

class DeliveryHistoryCard extends StatelessWidget {
  const DeliveryHistoryCard({super.key, required this.delivery});

  final DeliveryHistoryEntity delivery;

  bool get _isPaid => delivery.payoutStatus.toUpperCase() == 'SUCCESS';

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => context.push(
            RouteNames.historyDetail,
            extra: delivery,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.shortOrderId,
                          style: AppTextStyles.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.two_wheeler,
                              size: AppSpacing.iconSm,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              delivery.deliveryMode.toUpperCase(),
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _isPaid
                            ? AppColors.success
                            : AppColors.neutralGray,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        delivery.payoutStatus.toUpperCase(),
                        style: AppTextStyles.statusLabel.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.displayDate,
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          delivery.displayTime,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      delivery.displayEarned,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
