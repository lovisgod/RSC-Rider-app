import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/utils/formatters.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/earnings_entity.dart';

class EarningsSummaryCard extends StatelessWidget {
  const EarningsSummaryCard({super.key, required this.earnings});

  final EarningsEntity earnings;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.todayEarnings,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppFormatters.currency(earnings.today),
              style: AppTextStyles.earningsAmount,
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _Stat(
                  label: AppStrings.weekEarnings,
                  value: AppFormatters.currency(earnings.week),
                ),
                _Stat(
                  label: AppStrings.todayDeliveries,
                  value: '${earnings.todayDeliveries}',
                ),
                _Stat(
                  label: AppStrings.totalDeliveries,
                  value: '${earnings.totalDeliveries}',
                ),
              ],
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      );
}
