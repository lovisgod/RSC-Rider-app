import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/router/route_names.dart';
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

  // Adds an order built straight from a push notification payload — no API
  // round-trip, so it appears on the dashboard instantly. Guards against
  // showing the same order twice (e.g. a duplicate/retried notification).
  void addOrderFromNotification(AssignedOrderEntity order) {
    final exists = state.orders.any((o) => o.orderId == order.orderId);
    if (exists) {
      debugPrint('[RSC Rider] Order already in list: ${order.orderId}');
      return;
    }
    emit(state.copyWith(orders: [order, ...state.orders]));
    debugPrint('[RSC Rider] ✅ Order added from notification: ${order.orderId}');
  }

  Future<void> startDelivery(AssignedOrderEntity order) async {
    var resolvedOrder = order;

    // Orders built from a notification payload arrive without item details —
    // fetch the full list and swap in the matching order before proceeding.
    final hasItems =
        order.outlets.isNotEmpty && order.outlets.first.items.isNotEmpty;
    if (!hasItems) {
      try {
        final orders = await _getAssignedOrders();
        resolvedOrder = orders.firstWhere(
          (o) => o.orderId == order.orderId,
          orElse: () => order,
        );
      } catch (e) {
        debugPrint('[RSC Rider] Failed to fetch full order details: $e');
      }
    }

    emit(state.copyWith(activeDeliveryOrder: resolvedOrder));
    _locationBroadcastingService.updateMasterOrderId(resolvedOrder.orderId);

    unawaited(
      AppRouter.rootNavigatorKey.currentContext
          ?.push(RouteNames.activeDelivery, extra: resolvedOrder),
    );
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
