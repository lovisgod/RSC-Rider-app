import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';

// Shown while AuthNotifier reads secure storage on first launch.
// go_router redirect() takes over once isInitialized becomes true.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: AppColors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.appName,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AppLoader(color: AppColors.white),
            ],
          ),
        ),
      );
}
