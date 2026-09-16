import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Shared layout for the forgot/reset password screens: navy branded header
// with a white rounded card overlapping it.

class AuthFlowHeader extends StatelessWidget {
  const AuthFlowHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: 200 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      color: AppColors.navyDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFlowCard extends StatelessWidget {
  const AuthFlowCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
        // Navy behind the rounded corners so the card reads as overlapping
        // the header.
        color: AppColors.navyDark,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: child,
        ),
      );
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textLabel,
          fontWeight: FontWeight.w700,
        ),
      );
}
