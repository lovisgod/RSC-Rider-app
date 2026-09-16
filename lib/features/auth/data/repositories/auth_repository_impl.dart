import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rsc_rider/features/auth/data/models/forgot_password_request_model.dart';
import 'package:rsc_rider/features/auth/data/models/login_request_model.dart';
import 'package:rsc_rider/features/auth/data/models/reset_password_request_model.dart';
import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final LocalStorage _storage;

  @override
  Future<RiderEntity> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _dataSource.login(
      LoginRequestModel(identifier: identifier, password: password),
    );

    if (response.role != 'RIDER') {
      throw Exception(
        'This account is not a rider account. Please use the customer app.',
      );
    }

    await _storage.saveRiderId(response.id);
    await _storage.saveRiderRole(response.role);
    // The rider's name/email/phone now come from GET /users/me, fetched by
    // DashboardBloc on start — no need to cache a name here.
    return response.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Never block logout on a network failure — local state still clears.
    } finally {
      await _storage.clearSession();
    }
  }

  @override
  Future<int> forgotPassword(String identifier) async {
    final response = await _dataSource.forgotPassword(
      ForgotPasswordRequestModel(identifier: identifier),
    );
    return response.otpExpiresInSeconds;
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dataSource.resetPassword(
        ResetPasswordRequestModel(
          identifier: identifier,
          code: code,
          newPassword: newPassword,
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(AppStrings.invalidOrExpiredCode);
      }
      rethrow;
    }
  }
}
