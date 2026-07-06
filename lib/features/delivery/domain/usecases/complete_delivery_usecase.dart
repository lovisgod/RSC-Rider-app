import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/delivery_repository.dart';

class CompleteDeliveryUsecase {
  const CompleteDeliveryUsecase(this._repository);

  final DeliveryRepository _repository;

  Future<CompleteDeliveryResponseModel> call(String orderId, String code) =>
      _repository.completeDelivery(orderId, code);
}
