import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/code_box_input.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';

void showDeliveryCodeSheet(BuildContext context, {required AssignedOrderEntity order}) {
  final deliveryCubit = context.read<DeliveryCubit>();
  showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: deliveryCubit,
      child: DeliveryCodeSheet(order: order),
    ),
  );
}

class DeliveryCodeSheet extends StatefulWidget {
  const DeliveryCodeSheet({required this.order, super.key});

  final AssignedOrderEntity order;

  @override
  State<DeliveryCodeSheet> createState() => _DeliveryCodeSheetState();
}

class _DeliveryCodeSheetState extends State<DeliveryCodeSheet> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: BlocConsumer<DeliveryCubit, DeliveryState>(
                // Completion is handled by ActiveDeliveryScreen, which owns
                // closing this sheet and showing DeliverySuccessSheet — a
                // single BlocListener drives that transition to avoid two
                // listeners racing to pop routes off the same Navigator.
                listenWhen: (previous, current) =>
                    previous.status != current.status &&
                    current.status == DeliveryStatus.failed,
                listener: (context, state) {
                  AppSnackbar.showError(context, state.errorMessage!);
                  context.read<DeliveryCubit>().reset();
                  setState(() => _attempt++);
                },
                builder: (context, state) {
                  final cubit = context.read<DeliveryCubit>();
                  final isCompleting = state.status == DeliveryStatus.completing;
                  final canSubmit =
                      state.deliveryCode.trim().length == 6 && !isCompleting;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        AppStrings.confirmDelivery,
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        AppStrings.almostDone,
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.askCustomerCode,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                              widget.order.shortOrderId,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CodeBoxInput(
                        key: ValueKey(_attempt),
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
                                  orderId: widget.order.orderId,
                                  code: state.deliveryCode,
                                )
                            : null,
                      ),
                      if (!isCompleting) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppStrings.cancel,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
}
