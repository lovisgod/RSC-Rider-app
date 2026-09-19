import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/features/history/domain/entities/delivery_history_entity.dart';

class DeliveryHistoryDetailScreen extends StatelessWidget {
  const DeliveryHistoryDetailScreen({super.key, required this.delivery});

  final DeliveryHistoryEntity delivery;

  bool get _isPaid => delivery.payoutStatus.toUpperCase() == 'SUCCESS';

  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: delivery.masterOrderId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.orderIdCopied)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navyDark,
          centerTitle: true,
          title: Text(
            AppStrings.orderDetails,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    delivery.displayEarned,
                    style: AppTextStyles.earningsAmount.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${delivery.displayDate} · ${delivery.displayTime}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: AppStrings.orderId,
                    valueWidget: InkWell(
                      onTap: () => _copyOrderId(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              delivery.masterOrderId,
                              style: AppTextStyles.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.copy_outlined,
                            size: AppSpacing.iconSm,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _DetailRow(
                    label: AppStrings.deliveryMode,
                    valueWidget: Row(
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
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _DetailRow(
                    label: AppStrings.payoutStatus,
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _isPaid ? AppColors.success : AppColors.neutralGray,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        delivery.payoutStatus.toUpperCase(),
                        style: AppTextStyles.statusLabel.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _DetailRow(
                    label: AppStrings.completedOn,
                    valueWidget: Text(
                      '${delivery.displayDate}, ${delivery.displayTime}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  _DetailRow(
                    label: AppStrings.currency,
                    valueWidget: Text(
                      delivery.currency.toUpperCase(),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.valueWidget});

  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            valueWidget,
          ],
        ),
      );
}
