import 'package:rsc_rider/features/dashboard/domain/entities/rider_status_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/repositories/dashboard_repository.dart';

class SetAvailabilityUseCase {
  const SetAvailabilityUseCase(this._repository);

  final DashboardRepository _repository;

  Future<RiderStatusEntity> call({required bool isOnline}) =>
      _repository.setAvailability(isOnline: isOnline);
}
