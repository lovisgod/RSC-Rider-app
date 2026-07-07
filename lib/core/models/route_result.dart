import 'package:latlong2/latlong.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  String get displayDistance => distanceMeters < 1000
      ? '${distanceMeters.round()}m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)}km';

  String get displayDuration {
    final mins = (durationSeconds / 60).round();
    if (mins < 60) return '$mins mins';
    return '${mins ~/ 60}h ${mins % 60}m';
  }
}
