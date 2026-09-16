import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/core/widgets/code_box_input.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/auth/presentation/widgets/auth_flow_layout.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    super.key,
    required this.identifier,
    required this.otpExpiresInSeconds,
  });

  final String identifier;
  final int otpExpiresInSeconds;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.instance<AuthBloc>(),
        child: _ResetPasswordView(
          identifier: identifier,
          otpExpiresInSeconds: otpExpiresInSeconds,
        ),
      );
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({
    required this.identifier,
    required this.otpExpiresInSeconds,
  });

  final String identifier;
  final int otpExpiresInSeconds;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _code = '';
  // Bumped on failure to remount CodeBoxInput, which clears all 6 boxes.
  int _codeBoxGeneration = 0;

  Timer? _timer;
  late int _secondsLeft = widget.otpExpiresInSeconds;

  @override
  void initState() {
    super.initState();
    if (_secondsLeft > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _tick(Timer timer) {
    if (_secondsLeft <= 1) timer.cancel();
    setState(() => _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0);
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String? get _validationError {
    final next = _newPasswordController.text;
    final confirm = _confirmController.text;
    if (next.isEmpty || confirm.isEmpty) return null;
    if (next.length < 8) return AppStrings.passwordMinLength;
    if (next != confirm) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  bool get _canSubmit =>
      _code.length == 6 &&
      _newPasswordController.text.length >= 8 &&
      _newPasswordController.text == _confirmController.text;

  void _submit() {
    context.read<AuthBloc>().add(
          ResetPasswordSubmitted(
            identifier: widget.identifier,
            code: _code,
            newPassword: _newPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            AppSnackbar.showSuccess(context, AppStrings.passwordResetSuccess);
            // go() not push() so the back button can't return here.
            context.go(RouteNames.login);
          } else if (state is AuthFailure) {
            AppSnackbar.showError(context, state.message);
            // Clear the code boxes so the rider can retry with a new code.
            setState(() {
              _code = '';
              _codeBoxGeneration++;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final error = _validationError;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthFlowHeader(
                    emoji: '🔑',
                    title: AppStrings.resetPasswordTitle,
                    subtitle: AppStrings.resetPasswordSubtitle,
                  ),
                  AuthFlowCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthFieldLabel(AppStrings.verificationCode),
                        const SizedBox(height: AppSpacing.sm),
                        CodeBoxInput(
                          key: ValueKey(_codeBoxGeneration),
                          onChanged: (value) => setState(() => _code = value),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: Text(
                            _secondsLeft > 0
                                ? '${AppStrings.codeExpiresIn}$_formattedTime'
                                : AppStrings.codeExpired,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _secondsLeft > 0
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const AuthFieldLabel(AppStrings.newPassword),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _newPasswordController,
                          hint: AppStrings.minEightChars,
                          obscureText: true,
                          enabled: !isLoading,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AuthFieldLabel(AppStrings.confirmPassword),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _confirmController,
                          hint: AppStrings.reEnterPassword,
                          obscureText: true,
                          enabled: !isLoading,
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
                          label: AppStrings.resetPasswordTitle,
                          isLoading: isLoading,
                          onPressed:
                              _canSubmit && !isLoading ? _submit : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
