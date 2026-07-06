import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.instance<ProfileCubit>(),
        child: const _ChangePasswordView(),
      );
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? get _validationError {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) return null;
    if (next.length < 6) return AppStrings.passwordTooShort;
    if (next != confirm) return AppStrings.passwordsDoNotMatch;
    if (next == current) return AppStrings.newPasswordSameAsCurrent;
    return null;
  }

  bool get _canSubmit =>
      _currentController.text.isNotEmpty &&
      _newController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty &&
      _validationError == null;

  void _submit() {
    context.read<ProfileCubit>().changePassword(
          _currentController.text,
          _newController.text,
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            (current.successMessage != null &&
                current.successMessage != previous.successMessage) ||
            (current.error != null && current.error != previous.error),
        listener: (context, state) {
          if (state.successMessage != null) {
            AppSnackbar.showSuccess(context, state.successMessage!);
            context.pop();
          } else if (state.error != null) {
            AppSnackbar.showError(context, state.error!);
          }
        },
        builder: (context, state) {
          final error = _validationError;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.navyDark,
              title: Text(
                AppStrings.changePassword,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const Center(
                  child: Text('🔒', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _currentController,
                  label: AppStrings.currentPassword,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _newController,
                  label: AppStrings.newPassword,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirmController,
                  label: AppStrings.confirmNewPassword,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: AppStrings.updatePassword,
                  isLoading: state.isSubmitting,
                  onPressed:
                      _canSubmit && !state.isSubmitting ? _submit : null,
                ),
              ],
            ),
          );
        },
      );
}
