import 'package:rsc_rider/features/delivery/domain/repositories/rider_location_repository.dart';

class RecordRiderLocationUsecase {
  const RecordRiderLocationUsecase(this._repository);

  final RiderLocationRepository _repository;

  Future<void> call(
    double latitude,
    double longitude, {
    String? masterOrderId,
  }) =>
      _repository.recordLocation(
        latitude,
        longitude,
        masterOrderId: masterOrderId,
      );
}
