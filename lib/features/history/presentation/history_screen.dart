import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/utils/formatters.dart';
import 'package:rsc_rider/core/widgets/empty_state.dart';
import 'package:rsc_rider/core/widgets/error_view.dart';
import 'package:rsc_rider/features/history/presentation/cubit/history_cubit.dart';
import 'package:rsc_rider/features/history/presentation/cubit/history_state.dart';
import 'package:rsc_rider/features/history/presentation/widgets/delivery_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.instance<HistoryCubit>()..loadDeliveries(),
        child: const _HistoryView(),
      );
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navyDark,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            AppStrings.deliveryHistory,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.isLoading && state.deliveries.isEmpty) {
              return const _ShimmerList();
            }
            if (state.error != null && state.deliveries.isEmpty) {
              return ErrorView(
                message: state.error!,
                onRetry: () =>
                    context.read<HistoryCubit>().loadDeliveries(),
              );
            }
            return Column(
              children: [
                _EarningsSummaryCard(state: state),
                Expanded(
                  child: state.deliveries.isEmpty
                      ? const EmptyState(
                          icon: Icons.moped_outlined,
                          title: AppStrings.noDeliveriesYet,
                          subtitle: AppStrings.completeFirstDelivery,
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () =>
                              context.read<HistoryCubit>().loadDeliveries(),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(
                              AppSpacing.screenPadding,
                            ),
                            itemCount: state.deliveries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) =>
                                DeliveryHistoryCard(
                              delivery: state.deliveries[index],
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      );
}

class _EarningsSummaryCard extends StatelessWidget {
  const _EarningsSummaryCard({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(AppSpacing.screenPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: AppStrings.totalEarnings,
                amount: state.totalEarned,
                subtitle: '${state.totalFromApi} ${AppStrings.deliveries}',
              ),
            ),
            const SizedBox(
              height: 48,
              child: VerticalDivider(color: AppColors.divider, width: 1),
            ),
            Expanded(
              child: _SummaryItem(
                label: AppStrings.thisSession,
                amount: state.totalEarnings,
                subtitle: '${state.totalDeliveries} ${AppStrings.deliveries}',
              ),
            ),
          ],
        ),
      );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.subtitle,
  });

  final String label;
  final double amount;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppFormatters.currency(amount, decimals: false),
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      );
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => const _ShimmerCard(),
      );
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBlock(width: 90, height: 12),
              const Spacer(),
              _shimmerBlock(width: double.infinity, height: 12),
              const Spacer(),
              _shimmerBlock(width: 140, height: 16),
            ],
          ),
        ),
      );

  Widget _shimmerBlock({required double width, required double height}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      );
}
