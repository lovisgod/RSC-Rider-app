import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';

abstract interface class DeliveryRepository {
  Future<CompleteDeliveryResponseModel> completeDelivery(
    String orderId,
    String code,
  );

  Future<List<AssignedOrderEntity>> getAssignedOrders();

  Future<void> rejectOrder(String orderId, String reason);
}
