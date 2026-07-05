import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/profile/data/models/rider_profile_model.dart';
import 'package:rsc_rider/features/profile/data/models/update_rider_profile_request_model.dart';
import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';
import 'package:rsc_rider/features/profile/domain/repositories/rider_profile_repository.dart';

class RiderProfileRepositoryImpl implements RiderProfileRepository {
  const RiderProfileRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<RiderProfileEntity> getProfile() async {
    try {
      final response =
          await _client.dio.get<Map<String, dynamic>>(ApiEndpoints.userMe);
      return _entityFrom(response);
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  @override
  Future<RiderProfileEntity> updateProfile(
    String name,
    String phone,
    String email,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.userMe,
        data: UpdateRiderProfileRequestModel(
          name: name,
          phone: phone,
          email: email,
        ).toJson(),
      );
      return _entityFrom(response);
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  @override
  Future<RiderProfileEntity> uploadAvatar(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', ext == 'png' ? 'png' : 'jpeg'),
        ),
      });
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );
      return _entityFrom(response);
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _client.dio.post<void>(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Current password is incorrect');
      }
      throw Exception(_message(e));
    }
  }

  RiderProfileEntity _entityFrom(Response<Map<String, dynamic>> response) {
    final data = response.data!['data'] as Map<String, dynamic>;
    return RiderProfileModel.fromJson(data).toEntity();
  }

  String _message(DioException e) {
    if (e.response?.statusCode == 401) return AppStrings.sessionExpired;
    final error = e.error;
    return error is ApiFailure ? error.message : AppStrings.somethingWentWrong;
  }
}
