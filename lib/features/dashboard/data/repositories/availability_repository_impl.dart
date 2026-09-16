import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/dashboard/data/models/availability_response_model.dart';
import 'package:rsc_rider/features/dashboard/domain/repositories/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  const AvailabilityRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<bool> setAvailability(bool isAvailable) async {
    try {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.riderAvailability,
        data: {'isAvailable': isAvailable},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return AvailabilityResponseModel.fromJson(data).isAvailable;
    } on DioException catch (e) {
      // 401s are handled globally by SessionInterceptor — no special case.
      final error = e.error;
      throw Exception(
        error is ApiFailure ? error.message : AppStrings.somethingWentWrong,
      );
    }
  }
}
