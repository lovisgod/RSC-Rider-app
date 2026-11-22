import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';

// Shown while AuthNotifier reads secure storage on first launch.
// go_router redirect() takes over once isInitialized becomes true.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/dineout_logo_light.png',
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AppLoader(color: AppColors.textOnDark),
            ],
          ),
        ),
      );
}
