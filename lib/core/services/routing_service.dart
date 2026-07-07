import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:rsc_rider/core/models/route_result.dart';
import 'package:rsc_rider/core/utils/logger.dart';

// Free OSRM public routing API — no API key, no auth cookies. Kept on a
// plain Dio instance separate from the app's DioClient so the rider's
// session cookie is never sent to a third-party host.
class RoutingService {
  RoutingService() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static const String _baseUrl = 'http://router.project-osrm.org';

  final Dio _dio;

  Future<RouteResult?> getRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      return RouteResult(
        points: coordinates
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList(),
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
    } catch (e) {
      appLogger.w('[Routing] Failed to fetch OSRM route.', error: e);
      return null;
    }
  }
}
