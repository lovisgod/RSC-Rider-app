import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';

void showLogoutConfirmationSheet(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
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
            AppStrings.logout,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            AppStrings.logOutConfirmMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    authBloc.add(const AuthLogoutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(AppStrings.logout),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
