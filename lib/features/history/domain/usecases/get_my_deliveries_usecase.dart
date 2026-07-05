import 'package:rsc_rider/features/history/data/models/delivery_history_response_model.dart';
import 'package:rsc_rider/features/history/domain/repositories/delivery_history_repository.dart';

class GetMyDeliveriesUsecase {
  const GetMyDeliveriesUsecase(this._repository);

  final DeliveryHistoryRepository _repository;

  Future<DeliveryHistoryResponseModel> call() => _repository.getMyDeliveries();
}
