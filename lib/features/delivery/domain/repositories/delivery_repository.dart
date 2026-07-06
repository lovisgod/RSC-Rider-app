import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';

abstract interface class DeliveryRepository {
  Future<CompleteDeliveryResponseModel> completeDelivery(
    String orderId,
    String code,
  );
}
