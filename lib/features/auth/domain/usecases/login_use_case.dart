import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';
import 'package:rsc_rider/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<RiderEntity> call({
    required String identifier,
    required String password,
  }) =>
      _repository.login(identifier: identifier, password: password);
}
