import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/get_assigned_orders_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/reject_order_usecase.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_state.dart';

class ActiveOrdersCubit extends Cubit<ActiveOrdersState> {
  ActiveOrdersCubit(
    this._getAssignedOrders,
    this._rejectOrder,
    this._locationBroadcastingService,
  ) : super(const ActiveOrdersState());

  final GetAssignedOrdersUsecase _getAssignedOrders;
  final RejectOrderUsecase _rejectOrder;
  final LocationBroadcastingService _locationBroadcastingService;

  Timer? _pollTimer;
  bool _hasLoadedOnce = false;

  Future<void> loadAssignedOrders() async {
    if (!_hasLoadedOnce) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    try {
      final orders = await _getAssignedOrders();
      _hasLoadedOnce = true;
      emit(state.copyWith(orders: orders, isLoading: false, clearError: true));
    } catch (_) {
      // Keep showing the last known list; don't flash an error on a poll.
      emit(state.copyWith(isLoading: false));
    }
  }

  void startPolling() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadAssignedOrders(),
    );
    unawaited(loadAssignedOrders());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void startDelivery(AssignedOrderEntity order) {
    emit(state.copyWith(activeDeliveryOrder: order));
    _locationBroadcastingService.updateMasterOrderId(order.orderId);
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    emit(
      state.copyWith(
        isRejecting: true,
        rejectingOrderId: orderId,
        clearError: true,
      ),
    );
    try {
      await _rejectOrder(orderId, reason);
      emit(
        state.copyWith(
          orders: state.orders.where((o) => o.orderId != orderId).toList(),
          isRejecting: false,
          clearRejectingOrderId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRejecting: false,
          clearRejectingOrderId: true,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearActiveDelivery() {
    emit(state.copyWith(clearActiveDeliveryOrder: true));
    _locationBroadcastingService.updateMasterOrderId(null);
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
