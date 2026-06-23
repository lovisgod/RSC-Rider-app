import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rsc_rider/features/auth/data/models/login_request_model.dart';
import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._storage);

  final AuthRemoteDataSource _dataSource;
  final LocalStorage _storage;

  @override
  Future<RiderEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.login(
      LoginRequestModel(email: email, password: password),
    );
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _storage.saveRiderId(response.riderId);
    return response.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      // Always clear local session even if the API call fails.
      await _storage.clearSession();
    }
  }
}
