import 'package:rsc_rider/core/mock/mock_rider.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

// Returns fixed mock data instead of calling the real API. Kept around
// (unregistered in di.dart) as an easy fallback if the real endpoint breaks.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository(this._storage);

  final LocalStorage _storage;

  @override
  Future<RiderEntity> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    await _storage.saveRiderId(MockRider.id);
    await _storage.saveRiderRole(MockRider.role);
    await _storage.saveRiderName(MockRider.name);
    return const RiderEntity(riderId: MockRider.id, role: MockRider.role);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _storage.clearSession();
  }
}
