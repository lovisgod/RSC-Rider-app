import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';

abstract interface class AuthRepository {
  Future<RiderEntity> login({required String email, required String password});
  Future<void> logout();
}
