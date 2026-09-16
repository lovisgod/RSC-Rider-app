import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/reject_order_bottom_sheet.dart';

class AssignedOrderCard extends StatelessWidget {
  const AssignedOrderCard({required this.order, super.key});

  final AssignedOrderEntity order;

  bool get _isReady => order.status.toUpperCase() == 'READY';

  // Once the rider is out for delivery the order can no longer be rejected.
  bool get _canReject => order.status.toUpperCase() != 'OUT_FOR_DELIVERY';

  String? get _preparationNote {
    for (final outlet in order.outlets) {
      if (outlet.hasPreparationNote) return outlet.preparationNote;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds only this card's button while its dispatch detail is fetching.
    final isStarting = context.select(
      (ActiveOrdersCubit cubit) => cubit.state.startingOrderId == order.orderId,
    );

    return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.shortOrderId,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _isReady ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final outlet in order.outlets)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Text('🏪', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        outlet.outletName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${AppStrings.pickupCode}${outlet.pickupCode}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: AppSpacing.md, color: AppColors.divider),
            Text(
              '📍 ${order.deliveryAddress}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (order.totalItems > 0)
              Text(
                order.allItemsSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'Items: Loading...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (_preparationNote != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${AppStrings.preparationNote}$_preparationNote',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _canReject
                      ? OutlinedButton(
                          onPressed: () => showRejectOrderBottomSheet(
                            context,
                            orderId: order.orderId,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text(AppStrings.reject),
                        )
                      : IgnorePointer(
                          child: Opacity(
                            opacity: 0.5,
                            child: OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.neutralGray,
                                ),
                                disabledForegroundColor: AppColors.neutralGray,
                              ),
                              child: const Text(AppStrings.reject),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    // startDelivery fetches the dispatch detail and
                    // navigates to ActiveDeliveryScreen itself.
                    onPressed: isStarting
                        ? null
                        : () => context
                            .read<ActiveOrdersCubit>()
                            .startDelivery(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.textOnDark,
                    ),
                    child: isStarting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnDark,
                            ),
                          )
                        : const Text(
                            AppStrings.startDelivery,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
