import 'package:flutter/material.dart';

/// DineOut NG dark-column tokens — dark ships as the app's active default,
/// and most existing widgets read [AppColors.x] directly rather than
/// through `Theme.of(context)`, so these are the colors actually on screen.
/// [AppColorsLight] holds the light column and is consumed only by
/// [AppTheme.light]'s [ColorScheme].
abstract final class AppColors {
  // ─── Brand ───────────────────────────────────────────
  static const Color rscMain = Color(0xFF14883A);
  static const Color rscNavyDark = Color(0xFF0D5F2E);
  static const Color rscNavyLight = Color(0xFF245996);
  static const Color rscBrand = Color(0xFFFF8200);
  static const Color rscBrandLight = Color(0xFFFF9D2E);
  static const Color rscBrandStrong = Color(0xFFFF8200);

  // ─── Neutral / system ─────────────────────────────────
  static const Color rscInk = Color(0xFFF5F7F2);
  static const Color rscMuted = Color(0xFF9BA79F);
  static const Color rscSurface = Color(0xFF121713);
  static const Color rscPanel = Color(0xFF121713);
  static const Color rscLine = Color(0xFF3F4842);
  static const Color rscDanger = Color(0xFFF08070);
  static const Color rscSuccess = Color(0xFF50C982);

  /// Form fields (login, addresses, any bordered text field) stay white
  /// pills even against the dark theme — that's the real design, not a
  /// dark-mode gap. [rscFieldMuted] is calibrated for legibility on that
  /// white fill and is used for field hint/label text, not general text.
  static const Color rscFieldBg = Color(0xFFFFFFFF);
  static const Color rscFieldInk = Color(0xFF111712);
  static const Color rscFieldMuted = Color(0xFF6D7B70);

  // ─── Navigation ────────────────────────────────────────
  static const Color rscSidebarBg = Color(0xFF0F1712);
  static const Color rscSidebarInk = Color(0xFFF5F7F2);
  static const Color rscSidebarMuted = Color(0xFF9BA79F);
  static const Color rscBottomNavBg = Color(0xFF0F1712);
  static const Color rscBottomNavMuted = Color(0xFF9BA79F);

  /// No fixed hex in the source spec — approximated as brand at ~16%
  /// opacity over the sidebar background.
  static const Color rscSidebarActiveBg = Color(0x29FF8200);

  // ─── Legacy aliases ────────────────────────────────────
  // Old semantic names from the pre-rebrand palette, kept pointing at the
  // new tokens so existing call sites don't need a mass rename.
  static const Color primary = rscBrand;
  static const Color primaryLight = rscBrandLight;
  static const Color primaryDark = rscBrandStrong;

  static const Color navy = rscMain;
  static const Color navyLight = rscLine;
  static const Color navyDark = rscSidebarBg;

  static const Color background = rscSurface;
  static const Color surface = rscPanel;
  static const Color surfaceDark = rscSidebarBg;

  static const Color outletCardNavy = rscMain;
  static const Color outletCardGreen = rscSuccess;

  static const Color textPrimary = rscInk;
  static const Color textSecondary = rscMuted;
  static const Color textHint = rscMuted;
  static const Color textOnDark = rscInk;
  static const Color textLabel = rscMain;

  static const Color navActiveBackground = rscSidebarActiveBg;
  static const Color navActive = rscBrand;
  static const Color navInactive = rscMuted;

  static const Color error = rscDanger;
  static const Color success = rscSuccess;
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = rscNavyLight;
  static const Color neutralGray = rscMuted;

  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputBorderFocused = primary;
  static const Color divider = rscLine;
  static const Color shimmer = rscLine;

  static const Color starRating = rscBrand;

  // ─── Rider specific ───────────────────────────────────
  /// Online status indicator — rider is available
  static const Color onlineGreen = rscSuccess;

  /// Offline status indicator — rider is unavailable
  static const Color offlineRed = rscDanger;

  /// Active delivery highlight
  static const Color activeDelivery = rscMain;

  /// Earnings amount color
  static const Color earnings = rscSuccess;
}

/// DineOut NG light-column tokens. Consumed only by [AppTheme.light] — not
/// referenced by widgets directly.
abstract final class AppColorsLight {
  static const Color rscMain = Color(0xFF0B4F2D);
  static const Color rscNavyDark = Color(0xFF06391F);
  static const Color rscNavyLight = Color(0xFF245996);
  static const Color rscBrand = Color(0xFF14883A);
  static const Color rscBrandLight = Color(0xFF2AA856);
  static const Color rscBrandStrong = Color(0xFF0F6D30);

  static const Color rscInk = Color(0xFF171B17);
  static const Color rscMuted = Color(0xFF6D7B70);
  static const Color rscSurface = Color(0xFFF8FAF8);
  static const Color rscPanel = Color(0xFFFFFFFF);
  static const Color rscLine = Color(0xFFDCE6DF);
  static const Color rscDanger = Color(0xFFA33A2B);
  static const Color rscSuccess = Color(0xFF168A4A);

  static const Color rscFieldBg = Color(0xFFFFFFFF);
  static const Color rscFieldInk = Color(0xFF111712);
  static const Color rscFieldMuted = Color(0xFF6D7B70);

  static const Color rscSidebarBg = rscMain;
  static const Color rscSidebarInk = Color(0xFFFFFFFF);
  static const Color rscSidebarMuted = Color(0x94FFFFFF);
  static const Color rscBottomNavBg = rscSurface;
  static const Color rscBottomNavMuted = rscMuted;

  static const Color rscSidebarActiveBg = Color(0x2914883A);
}
