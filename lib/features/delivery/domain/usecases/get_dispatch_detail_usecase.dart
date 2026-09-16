import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';

class GetDispatchDetailUsecase {
  const GetDispatchDetailUsecase(this._repository);

  final DeliveryRepository _repository;

  Future<AssignedOrderEntity> call(String orderId) =>
      _repository.getDispatchDetail(orderId);
}
