import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/dashboard/data/models/active_delivery_summary_model.dart';
import 'package:rsc_rider/features/dashboard/data/models/earnings_model.dart';
import 'package:rsc_rider/features/dashboard/data/models/rider_status_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._client);

  final DioClient _client;

  Future<RiderStatusModel> getStatus() async {
    final response = await _client.dio
        .get<Map<String, dynamic>>(ApiEndpoints.riderProfile);
    return RiderStatusModel.fromJson(response.data!);
  }

  Future<RiderStatusModel> setAvailability(bool isOnline) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      ApiEndpoints.toggleAvailability,
      data: {'is_online': isOnline},
    );
    return RiderStatusModel.fromJson(response.data!);
  }

  Future<EarningsModel> getEarnings() async {
    final response =
        await _client.dio.get<Map<String, dynamic>>(ApiEndpoints.earnings);
    return EarningsModel.fromJson(response.data!);
  }

  // Returns null when the rider has no active delivery (backend responds 404).
  Future<ActiveDeliverySummaryModel?> getActiveDelivery() async {
    try {
      final response = await _client.dio
          .get<Map<String, dynamic>>(ApiEndpoints.activeDelivery);
      final data = response.data;
      if (data == null) return null;
      return ActiveDeliverySummaryModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
