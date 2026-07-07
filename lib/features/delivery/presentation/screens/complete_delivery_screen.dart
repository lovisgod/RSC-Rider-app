import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/code_box_input.dart';
import 'package:rsc_rider/core/widgets/empty_state.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_state.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/delivery_success_sheet.dart';

class CompleteDeliveryScreen extends StatelessWidget {
  const CompleteDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GetIt.instance<DeliveryCubit>()),
          BlocProvider.value(value: GetIt.instance<ActiveOrdersCubit>()),
        ],
        child: const _CompleteDeliveryView(),
      );
}

class _CompleteDeliveryView extends StatelessWidget {
  const _CompleteDeliveryView();

  @override
  Widget build(BuildContext context) => BlocListener<DeliveryCubit, DeliveryState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == DeliveryStatus.completed) {
            final cubit = context.read<DeliveryCubit>();
            showModalBottomSheet<void>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => DeliverySuccessSheet(
                delivery: state.completedDelivery!,
                onBackToDashboard: cubit.reset,
              ),
            );
          } else if (state.status == DeliveryStatus.failed) {
            AppSnackbar.showError(context, state.errorMessage!);
            context.read<DeliveryCubit>().reset();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.navyDark,
            title: Text(
              AppStrings.completeDelivery,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
          ),
          body: BlocBuilder<ActiveOrdersCubit, ActiveOrdersState>(
            builder: (context, activeOrdersState) {
              final order = activeOrdersState.activeDeliveryOrder;
              if (order == null) {
                return const EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: AppStrings.noAssignedOrders,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: BlocBuilder<DeliveryCubit, DeliveryState>(
                  builder: (context, state) {
                    final cubit = context.read<DeliveryCubit>();
                    final isCompleting = state.status == DeliveryStatus.completing;
                    final canSubmit =
                        state.deliveryCode.trim().length == 6 && !isCompleting;

                    return Column(
                      children: [
                        const Center(
                          child: Text('📦', style: TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          AppStrings.confirmDelivery,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppStrings.askCustomerCode,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
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
                              Text(
                                AppStrings.orderLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                order.shortOrderId,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      order.deliveryAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppStrings.customerDeliveryCode,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textLabel,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CodeBoxInput(
                          hasError: state.codeError != null,
                          onChanged: cubit.updateDeliveryCode,
                        ),
                        if (state.codeError != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              state.codeError!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: isCompleting
                              ? AppStrings.verifying
                              : AppStrings.completeDelivery,
                          isLoading: isCompleting,
                          onPressed: canSubmit
                              ? () => cubit.completeDelivery(
                                    orderId: order.orderId,
                                    code: state.deliveryCode,
                                  )
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
}
