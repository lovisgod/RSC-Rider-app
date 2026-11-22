import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/delivery/data/models/rider_location_request_model.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/rider_location_repository.dart';

class RiderLocationRepositoryImpl implements RiderLocationRepository {
  const RiderLocationRepositoryImpl(this._client);

  final DioClient _client;

  // Failures are classified into the typed exceptions below so
  // LocationBroadcastingService can back off, retry, or drop the fix —
  // it never lets one propagate further and crash the app.
  @override
  Future<void> recordLocation(
    double latitude,
    double longitude, {
    String? masterOrderId,
  }) async {
    try {
      await _client.dio.post<void>(
        ApiEndpoints.recordRiderLocation,
        data: RiderLocationRequestModel(
          latitude: latitude,
          longitude: longitude,
          masterOrderId: masterOrderId,
        ).toJson(),
      );
    } on DioException catch (e) {
      // 401s are handled globally by SessionInterceptor (which also stops
      // this broadcast's timer) — swallow it here rather than retrying.
      if (e.response?.statusCode == 401) return;

      appLogger.w('[RiderLocation] Failed to record location.', error: e);
      switch (e.response?.statusCode) {
        case 429:
          throw LocationRateLimitedException(_retryAfter(e));
        case 403:
          throw const LocationOrderNotAssignedException();
        case 400:
        case 422:
          throw const LocationRejectedException();
        default:
          throw const LocationTransientException();
      }
    }
  }

  Duration _retryAfter(DioException e) {
    final header = e.response?.headers.value('retry-after');
    final seconds = header == null ? null : int.tryParse(header);
    return Duration(seconds: seconds ?? 10);
  }
}
