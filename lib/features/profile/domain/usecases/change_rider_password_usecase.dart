import 'package:rsc_rider/features/profile/domain/repositories/rider_profile_repository.dart';

class ChangeRiderPasswordUsecase {
  const ChangeRiderPasswordUsecase(this._repository);

  final RiderProfileRepository _repository;

  Future<void> call(String currentPassword, String newPassword) =>
      _repository.changePassword(currentPassword, newPassword);
}
