import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/features/auth/data/models/forgot_password_request_model.dart';
import 'package:rsc_rider/features/auth/data/models/forgot_password_response_model.dart';
import 'package:rsc_rider/features/auth/data/models/login_request_model.dart';
import 'package:rsc_rider/features/auth/data/models/login_response_model.dart';
import 'package:rsc_rider/features/auth/data/models/reset_password_request_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _client.dio.post<void>(ApiEndpoints.logout);
  }

  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
    );
    return ForgotPasswordResponseModel.fromJson(response.data!);
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    await _client.dio.post<void>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
  }
}
