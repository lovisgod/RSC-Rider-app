import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

final class DarkTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.navyLight,
      onPrimary: AppColors.textOnDark,
      secondary: AppColors.onlineGreen,
      onSecondary: Colors.black,
      error: AppColors.error,
      onError: AppColors.textOnDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textOnDark,
      surfaceContainerHighest: AppColors.navyDark,
      onSurfaceVariant: AppColors.neutralGray,
      outline: AppColors.navyLight,
    ),
    scaffoldBackgroundColor: AppColors.surfaceDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navyDark,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.textOnDark,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navyDark,
      indicatorColor: AppColors.navActiveBackground,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.navActive
              : AppColors.navInactive,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTextStyles.labelSmall.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.navActive
              : AppColors.navInactive,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyLight,
        foregroundColor: AppColors.textOnDark,
        disabledBackgroundColor: AppColors.navyDark,
        disabledForegroundColor: AppColors.neutralGray,
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
        foregroundColor: AppColors.primaryLight,
        disabledForegroundColor: AppColors.neutralGray,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.inputPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.navyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.navyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textHint,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.neutralGray,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.error,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.navyLight),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.navyLight,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.navyDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      side: BorderSide.none,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.neutralGray,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textOnDark,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.textOnDark,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textOnDark),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textOnDark,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.neutralGray,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textOnDark,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.neutralGray,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.neutralGray,
      ),
    ),
  );
}
