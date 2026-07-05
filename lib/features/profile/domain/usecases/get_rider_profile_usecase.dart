import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';
import 'package:rsc_rider/features/profile/domain/repositories/rider_profile_repository.dart';

class GetRiderProfileUsecase {
  const GetRiderProfileUsecase(this._repository);

  final RiderProfileRepository _repository;

  Future<RiderProfileEntity> call() => _repository.getProfile();
}
