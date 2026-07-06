import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/complete_delivery_usecase.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit({
    required this._completeDelivery,
    required this._locationBroadcastingService,
  }) : super(const DeliveryState());

  final CompleteDeliveryUsecase _completeDelivery;
  final LocationBroadcastingService _locationBroadcastingService;

  void updateOrderId(String value) {
    emit(state.copyWith(orderId: value, clearOrderIdError: true));
  }

  void updateDeliveryCode(String value) {
    emit(state.copyWith(deliveryCode: value, clearCodeError: true));
  }

  Future<void> completeDelivery() async {
    final orderId = state.orderId.trim();
    final code = state.deliveryCode.trim();

    if (orderId.isEmpty) {
      emit(state.copyWith(orderIdError: AppStrings.pleaseEnterOrderId));
      return;
    }
    if (code.length != 6) {
      emit(state.copyWith(codeError: AppStrings.codeMustBeSixDigits));
      return;
    }

    emit(state.copyWith(status: DeliveryStatus.completing));
    try {
      final response = await _completeDelivery(orderId, code);
      _locationBroadcastingService.updateMasterOrderId(null);
      emit(
        state.copyWith(
          status: DeliveryStatus.completed,
          completedDelivery: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryStatus.failed,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void reset() => emit(const DeliveryState());
}
