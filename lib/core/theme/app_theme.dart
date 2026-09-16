import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorsLight.rscMain,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColorsLight.rscMain,
      onPrimary: Colors.white,
      secondary: AppColorsLight.rscBrand,
      onSecondary: Colors.white,
      error: AppColorsLight.rscDanger,
      onError: Colors.white,
      surface: AppColorsLight.rscPanel,
      onSurface: AppColorsLight.rscInk,
      surfaceContainerHighest: AppColorsLight.rscSurface,
      onSurfaceVariant: AppColorsLight.rscMuted,
      outline: AppColorsLight.rscLine,
    ),
    scaffoldBackgroundColor: AppColorsLight.rscSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.rscSidebarBg,
      foregroundColor: AppColorsLight.rscSidebarInk,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(
        color: AppColorsLight.rscSidebarInk,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorsLight.rscBottomNavBg,
      indicatorColor: AppColorsLight.rscSidebarActiveBg,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColorsLight.rscBrand
              : AppColorsLight.rscBottomNavMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTextStyles.labelSmall.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColorsLight.rscBrand
              : AppColorsLight.rscBottomNavMuted,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.rscMain,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColorsLight.rscLine,
        disabledForegroundColor: AppColorsLight.rscMuted,
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
        foregroundColor: AppColorsLight.rscBrand,
        disabledForegroundColor: AppColorsLight.rscMuted,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        side: const BorderSide(color: AppColorsLight.rscBrand),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsLight.rscBrand,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.rscFieldBg,
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
        borderSide: const BorderSide(
          color: AppColorsLight.rscBrand,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColorsLight.rscDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColorsLight.rscDanger, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsLight.rscFieldMuted,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsLight.rscFieldMuted,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColorsLight.rscDanger,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColorsLight.rscPanel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColorsLight.rscLine),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsLight.rscPanel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsLight.rscLine,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsLight.rscSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      side: BorderSide.none,
      labelStyle: AppTextStyles.labelMedium,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
  );
}
