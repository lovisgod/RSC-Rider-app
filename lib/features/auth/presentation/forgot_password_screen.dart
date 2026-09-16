import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/utils/validators.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/auth/presentation/widgets/auth_flow_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.instance<AuthBloc>(),
        child: const _ForgotPasswordView(),
      );
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ForgotPasswordSubmitted(_identifierController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            context.push(
              RouteNames.resetPassword,
              extra: {
                'identifier': state.identifier,
                'otpExpiresInSeconds': state.otpExpiresInSeconds,
              },
            );
          } else if (state is AuthFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthFlowHeader(
                    emoji: '🔐',
                    title: AppStrings.forgotPasswordTitle,
                    subtitle: AppStrings.forgotPasswordSubtitle,
                  ),
                  AuthFlowCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthFieldLabel(AppStrings.phoneOrEmail),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _identifierController,
                            hint: AppStrings.identifierHint,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            enabled: !isLoading,
                            validator: Validators.required,
                            onChanged: (_) => setState(() {}),
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: AppStrings.sendResetCode,
                            isLoading: isLoading,
                            onPressed: isLoading ||
                                    _identifierController.text.trim().isEmpty
                                ? null
                                : _submit,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.rememberPassword,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  AppStrings.signIn,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
