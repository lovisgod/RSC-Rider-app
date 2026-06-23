import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = AppSpacing.iconMd, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

// Full-screen blocking loader — used during initial auth, deep data fetches.
class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoader(size: 48),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(message!, style: AppTextStyles.bodyMedium),
              ],
            ],
          ),
        ),
      );
}
