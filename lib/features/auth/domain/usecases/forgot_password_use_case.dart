import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  /// Returns how many seconds the OTP is valid for.
  Future<int> call(String identifier) => _repository.forgotPassword(identifier);
}
