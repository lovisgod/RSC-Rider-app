import 'package:rsc_rider/features/dashboard/domain/repositories/availability_repository.dart';

class SetAvailabilityUseCase {
  const SetAvailabilityUseCase(this._repository);

  final AvailabilityRepository _repository;

  // Returns the backend-confirmed availability — callers must adopt this
  // value rather than assume the request succeeded as sent.
  Future<bool> call({required bool isAvailable}) =>
      _repository.setAvailability(isAvailable);
}
