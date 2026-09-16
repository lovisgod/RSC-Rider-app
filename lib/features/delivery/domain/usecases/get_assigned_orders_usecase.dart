import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';

class GetAssignedOrdersUsecase {
  const GetAssignedOrdersUsecase(this._repository);

  final DeliveryRepository _repository;

  Future<List<AssignedOrderEntity>> call() => _repository.getAssignedOrders();
}
