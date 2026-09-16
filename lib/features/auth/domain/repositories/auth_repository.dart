import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';

abstract interface class AuthRepository {
  Future<RiderEntity> login({
    required String identifier,
    required String password,
  });
  Future<void> logout();

  /// Returns how many seconds the OTP is valid for.
  Future<int> forgotPassword(String identifier);

  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  });
}
