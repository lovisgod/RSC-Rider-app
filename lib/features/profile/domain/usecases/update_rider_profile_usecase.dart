import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';
import 'package:rsc_rider/features/profile/domain/repositories/rider_profile_repository.dart';

class UpdateRiderProfileUsecase {
  const UpdateRiderProfileUsecase(this._repository);

  final RiderProfileRepository _repository;

  Future<RiderProfileEntity> call(String name, String phone, String email) =>
      _repository.updateProfile(name, phone, email);
}
