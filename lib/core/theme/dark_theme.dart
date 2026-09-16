import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

final class DarkTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.rscMain,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.rscMain,
      onPrimary: Colors.white,
      secondary: AppColors.rscBrand,
      onSecondary: Colors.white,
      error: AppColors.rscDanger,
      onError: Colors.black,
      surface: AppColors.rscPanel,
      onSurface: AppColors.rscInk,
      surfaceContainerHighest: AppColors.rscSurface,
      onSurfaceVariant: AppColors.rscMuted,
      outline: AppColors.rscLine,
    ),
    scaffoldBackgroundColor: AppColors.rscSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.rscSidebarBg,
      foregroundColor: AppColors.rscSidebarInk,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.rscSidebarInk,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.rscBottomNavBg,
      indicatorColor: AppColors.rscSidebarActiveBg,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.rscBrand
              : AppColors.rscBottomNavMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTextStyles.labelSmall.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.rscBrand
              : AppColors.rscBottomNavMuted,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rscMain,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.rscLine,
        disabledForegroundColor: AppColors.rscMuted,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.button,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.rscBrand,
        disabledForegroundColor: AppColors.rscMuted,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        side: const BorderSide(color: AppColors.rscBrand),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.rscBrand,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Form fields stay white even on the dark theme — see AppColors.rscFieldBg.
      filled: true,
      fillColor: AppColors.rscFieldBg,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.inputPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.rscBrand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.rscDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.rscDanger, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.rscFieldMuted,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.rscFieldMuted,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.rscDanger,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.rscPanel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.rscLine),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.rscPanel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.rscLine,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.rscSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      side: BorderSide.none,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.rscMuted,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.rscInk,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.rscInk,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.rscInk,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.rscInk,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.rscInk,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.rscInk),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.rscInk),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.rscMuted),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.rscInk),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.rscMuted,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.rscMuted,
      ),
    ),
  );
}
