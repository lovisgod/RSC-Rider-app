import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String identifier,
    required String code,
    required String newPassword,
  }) =>
      _repository.resetPassword(
        identifier: identifier,
        code: code,
        newPassword: newPassword,
      );
}
