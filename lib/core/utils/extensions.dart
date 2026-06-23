import 'package:flutter/material.dart';
import 'package:rsc_rider/core/utils/formatters.dart';

// ── BuildContext ──────────────────────────────────────────────────────────────

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  bool get isSmallScreen => MediaQuery.sizeOf(this).width < 360;

  void unfocus() => FocusScope.of(this).unfocus();
}

// ── String ────────────────────────────────────────────────────────────────────

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  bool get isValidEmail {
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return regex.hasMatch(trim());
  }

  // Returns null if blank, otherwise trims.
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}

extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
}

// ── double ────────────────────────────────────────────────────────────────────

extension DoubleX on double {
  String toCurrency({String symbol = '₦'}) =>
      AppFormatters.currency(this, symbol: symbol);

  String toDistance() => AppFormatters.distance(this);
}

// ── int ───────────────────────────────────────────────────────────────────────

extension IntX on int {
  String toDuration() => AppFormatters.duration(this);

  // Shorthand for SizedBox spacing.
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

// ── DateTime ──────────────────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  String get toFormattedDate => AppFormatters.date(this);
  String get toFormattedTime => AppFormatters.time(this);
  String get toFormattedDateTime => AppFormatters.dateTime(this);
  String get toRelativeTime => AppFormatters.relativeTime(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
