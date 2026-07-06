import 'package:rsc_rider/features/history/data/models/delivery_history_response_model.dart';

abstract interface class DeliveryHistoryRepository {
  Future<DeliveryHistoryResponseModel> getMyDeliveries();
}
