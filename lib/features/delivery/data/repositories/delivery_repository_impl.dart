import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/delivery/data/models/complete_delivery_request_model.dart';
import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  const DeliveryRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<CompleteDeliveryResponseModel> completeDelivery(
    String orderId,
    String code,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.completeDelivery(orderId),
        data: CompleteDeliveryRequestModel(code).toJson(),
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return CompleteDeliveryResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  String _message(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return AppStrings.invalidDeliveryCode;
      case 401:
        return AppStrings.sessionExpired;
      case 403:
        return AppStrings.orderNotAssigned;
      case 404:
        return AppStrings.orderNotFound;
    }
    final error = e.error;
    return error is ApiFailure ? error.message : AppStrings.somethingWentWrong;
  }
}
