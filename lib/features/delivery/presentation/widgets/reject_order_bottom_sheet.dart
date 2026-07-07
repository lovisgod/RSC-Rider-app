import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_state.dart';

const List<String> _suggestedReasons = [
  AppStrings.suggestedReasonBikeIssue,
  AppStrings.suggestedReasonTooFar,
  AppStrings.suggestedReasonEmergency,
  AppStrings.suggestedReasonTraffic,
  AppStrings.suggestedReasonAddress,
  AppStrings.suggestedReasonOther,
];

void showRejectOrderBottomSheet(
  BuildContext context, {
  required String orderId,
}) {
  final activeOrdersCubit = context.read<ActiveOrdersCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: activeOrdersCubit,
      child: _RejectOrderSheet(orderId: orderId),
    ),
  );
}

class _RejectOrderSheet extends StatefulWidget {
  const _RejectOrderSheet({required this.orderId});

  final String orderId;

  @override
  State<_RejectOrderSheet> createState() => _RejectOrderSheetState();
}

class _RejectOrderSheetState extends State<_RejectOrderSheet> {
  final _reasonController = TextEditingController();
  String? _selectedChip;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _selectChip(String reason) {
    setState(() {
      _selectedChip = reason;
      _reasonController.text = reason;
    });
  }

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
              child: BlocConsumer<ActiveOrdersCubit, ActiveOrdersState>(
                listenWhen: (previous, current) =>
                    previous.isRejecting &&
                    !current.isRejecting &&
                    !current.orders.any((o) => o.orderId == widget.orderId),
                listener: (context, state) => Navigator.pop(context),
                builder: (context, state) {
                  final isRejecting = state.isRejecting &&
                      state.rejectingOrderId == widget.orderId;
                  final reason = _reasonController.text.trim();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        AppStrings.rejectOrder,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.whyRejecting,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final chip in _suggestedReasons)
                            _ReasonChip(
                              label: chip,
                              selected: _selectedChip == chip,
                              onTap: () => _selectChip(chip),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        AppStrings.orTypeYourReason,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _reasonController,
                        hint: AppStrings.describeYourReason,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton.danger(
                        label: AppStrings.confirmRejection,
                        isLoading: isRejecting,
                        onPressed: reason.isEmpty
                            ? null
                            : () async {
                                final cubit = context.read<ActiveOrdersCubit>();
                                await cubit.rejectOrder(widget.orderId, reason);
                                if (!context.mounted) return;
                                final error = cubit.state.error;
                                if (error != null) {
                                  AppSnackbar.showError(context, error);
                                }
                              },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed:
                            isRejecting ? null : () => Navigator.pop(context),
                        child: Text(
                          AppStrings.cancel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.textOnDark : AppColors.textSecondary,
            ),
          ),
        ),
      );
}
