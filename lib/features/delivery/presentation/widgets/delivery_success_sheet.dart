import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';
import 'package:rsc_rider/features/history/presentation/cubit/history_cubit.dart';

class DeliverySuccessSheet extends StatelessWidget {
  const DeliverySuccessSheet({
    super.key,
    required this.delivery,
    required this.onBackToDashboard,
  });

  final CompleteDeliveryResponseModel delivery;
  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              AppStrings.deliveryComplete,
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                  const Text(
                    AppStrings.orderLabel,
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    delivery.shortOrderId,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.addressLabel,
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    delivery.deliveryAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    AppStrings.earningsLabel,
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    delivery.displayTotal,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.backToDashboard,
              onPressed: () {
                Navigator.pop(context);
                onBackToDashboard();
                GetIt.instance<HistoryCubit>().loadDeliveries();
                context.go(RouteNames.dashboard);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
