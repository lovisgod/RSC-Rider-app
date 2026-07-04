import 'package:rsc_rider/core/mock/mock_rider.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

// Returns fixed mock data instead of calling the real API — the rider auth
// endpoint isn't confirmed yet. Swap back to AuthRepositoryImpl in di.dart
// once it is.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository(this._storage);

  final LocalStorage _storage;

  @override
  Future<RiderEntity> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    await _storage.saveTokens(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
    );
    await _storage.saveRiderId(MockRider.id);
    await _storage.saveRiderName(MockRider.name);
    return RiderEntity(riderId: MockRider.id, email: email);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _storage.clearSession();
  }
}
