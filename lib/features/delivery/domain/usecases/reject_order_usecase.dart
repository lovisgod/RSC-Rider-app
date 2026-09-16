import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';

class RejectOrderUsecase {
  const RejectOrderUsecase(this._repository);

  final DeliveryRepository _repository;

  Future<void> call(String orderId, String reason) =>
      _repository.rejectOrder(orderId, reason);
}
