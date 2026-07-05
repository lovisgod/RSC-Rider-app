import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';
import 'package:rsc_rider/features/delivery/presentation/widgets/delivery_success_sheet.dart';

class CompleteDeliveryScreen extends StatelessWidget {
  const CompleteDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.instance<DeliveryCubit>(),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BlocBuilder<DeliveryCubit, DeliveryState>(
              builder: (context, state) {
                final cubit = context.read<DeliveryCubit>();
                final isCompleting = state.status == DeliveryStatus.completing;
                final canSubmit = state.orderId.trim().isNotEmpty &&
                    state.deliveryCode.trim().length == 6 &&
                    !isCompleting;

                return Column(
                  children: [
                    const Center(
                      child: Text('📦', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      AppStrings.enterDeliveryDetails,
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.enterDetailsSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.orderId,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textLabel,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      hint: AppStrings.orderIdHint,
                      keyboardType: TextInputType.text,
                      onChanged: cubit.updateOrderId,
                    ),
                    if (state.orderIdError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.orderIdError!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
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
                    _CodeBoxInput(
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
                      onPressed: canSubmit ? cubit.completeDelivery : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _CodeBoxInput extends StatefulWidget {
  const _CodeBoxInput({required this.onChanged, this.hasError = false});

  final ValueChanged<String> onChanged;
  final bool hasError;

  @override
  State<_CodeBoxInput> createState() => _CodeBoxInputState();
}

class _CodeBoxInputState extends State<_CodeBoxInput> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          6,
          (index) => SizedBox(
            width: 44,
            height: 52,
            child: Focus(
              onKeyEvent: (node, event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTextStyles.headlineSmall,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.inputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.inputBorderFocused,
                    ),
                  ),
                ),
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        ),
      );
}
