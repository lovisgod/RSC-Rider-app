import 'package:intl/intl.dart';

abstract final class AppFormatters {
  // Currency — defaults to Naira (₦)
  static String currency(double amount, {String symbol = '₦'}) =>
      '$symbol${NumberFormat('#,##0.00').format(amount)}';

  // Distance — meters → "350m" or "1.4km"
  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  // Duration — seconds → "5min", "1h 20min", "2h"
  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining > 0 ? '${hours}h ${remaining}min' : '${hours}h';
  }

  // Date — "23 Jun 2026"
  static String date(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

  // Time — "2:30 PM"
  static String time(DateTime dt) => DateFormat('h:mm a').format(dt);

  // DateTime — "23 Jun, 2:30 PM"
  static String dateTime(DateTime dt) =>
      DateFormat('d MMM, h:mm a').format(dt);

  // Relative time — "Just now", "5m ago", "2h ago", "3d ago"
  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Compact number — 1500 → "1.5K", 2000000 → "2M"
  static String compactNumber(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}
