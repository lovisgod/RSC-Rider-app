import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/delivery/data/models/rider_location_request_model.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/rider_location_repository.dart';

class RiderLocationRepositoryImpl implements RiderLocationRepository {
  const RiderLocationRepositoryImpl(this._client);

  final DioClient _client;

  // Location broadcasting must never crash the app or interrupt the rider's
  // flow — every failure is logged and swallowed, never rethrown.
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
    } catch (e) {
      // 401s are handled globally by SessionInterceptor (which also stops
      // this broadcast's timer) — everything else is just logged.
      appLogger.w('[RiderLocation] Failed to record location.', error: e);
    }
  }
}
