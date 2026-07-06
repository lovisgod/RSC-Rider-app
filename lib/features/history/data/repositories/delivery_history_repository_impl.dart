import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/history/data/models/delivery_history_response_model.dart';
import 'package:rsc_rider/features/history/domain/repositories/delivery_history_repository.dart';

class DeliveryHistoryRepositoryImpl implements DeliveryHistoryRepository {
  const DeliveryHistoryRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<DeliveryHistoryResponseModel> getMyDeliveries() async {
    try {
      final response = await _client.dio
          .get<Map<String, dynamic>>(ApiEndpoints.riderDeliveries);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return DeliveryHistoryResponseModel.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(AppStrings.sessionExpired);
      }
      final error = e.error;
      throw Exception(
        error is ApiFailure ? error.message : AppStrings.somethingWentWrong,
      );
    }
  }
}
