import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand ───────────────────────────────────────────
  static const Color primary = Color(0xFFD4832A);
  static const Color primaryLight = Color(0xFFE09A4A);
  static const Color primaryDark = Color(0xFFB86E1A);

  static const Color navy = Color(0xFF1E3160);
  static const Color navyLight = Color(0xFF253972);
  static const Color navyDark = Color(0xFF141F3D);

  // ─── Backgrounds ─────────────────────────────────────
  static const Color background = Color(0xFFF0F2F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2B52);

  // ─── Outlet card accent backgrounds ──────────────────
  static const Color outletCardNavy = Color(0xFF1E3160);
  static const Color outletCardGreen = Color(0xFF2E6B45);

  // ─── Text ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textLabel = Color(0xFF1E3160);

  // ─── Bottom nav ───────────────────────────────────────
  static const Color navActiveBackground = Color(0xFFF5EFE6);
  static const Color navActive = Color(0xFFD4832A);
  static const Color navInactive = Color(0xFF6B7280);

  // ─── Semantic ─────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF2196F3);
  static const Color neutralGray = Color(0xFF9CA3AF);

  // ─── UI ───────────────────────────────────────────────
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputBorderFocused = Color(0xFF1E3160);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmer = Color(0xFFE0E0E0);

  // ─── Rating ───────────────────────────────────────────
  static const Color starRating = Color(0xFFD4832A);

  // ─── Rider specific ───────────────────────────────────
  /// Online status indicator — rider is available
  static const Color onlineGreen = Color(0xFF43A047);

  /// Offline status indicator — rider is unavailable
  static const Color offlineRed = Color(0xFFE53935);

  /// Active delivery highlight
  static const Color activeDelivery = Color(0xFF1E3160);

  /// Earnings amount color
  static const Color earnings = Color(0xFF43A047);
}
