import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/complete_delivery_usecase.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit({
    required CompleteDeliveryUsecase completeDelivery,
    required LocationBroadcastingService locationBroadcastingService,
    required ActiveOrdersCubit activeOrdersCubit,
  })  : _completeDelivery = completeDelivery,
        _locationBroadcastingService = locationBroadcastingService,
        _activeOrdersCubit = activeOrdersCubit,
        super(const DeliveryState());

  final CompleteDeliveryUsecase _completeDelivery;
  final LocationBroadcastingService _locationBroadcastingService;
  final ActiveOrdersCubit _activeOrdersCubit;

  void updateDeliveryCode(String value) {
    emit(state.copyWith(deliveryCode: value, clearCodeError: true));
  }

  Future<void> completeDelivery({
    required String orderId,
    required String code,
  }) async {
    if (code.trim().length != 6) {
      emit(state.copyWith(codeError: AppStrings.codeMustBeSixDigits));
      return;
    }

    emit(state.copyWith(status: DeliveryStatus.completing));
    try {
      final response = await _completeDelivery(orderId, code.trim());
      _locationBroadcastingService.updateMasterOrderId(null);
      _activeOrdersCubit.clearActiveDelivery();
      unawaited(_activeOrdersCubit.loadAssignedOrders());
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
