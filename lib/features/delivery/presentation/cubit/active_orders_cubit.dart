import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/get_assigned_orders_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/get_dispatch_detail_usecase.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/reject_order_usecase.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_state.dart';

class ActiveOrdersCubit extends Cubit<ActiveOrdersState> {
  ActiveOrdersCubit(
    this._getAssignedOrders,
    this._rejectOrder,
    this._getDispatchDetail,
    this._locationBroadcastingService,
  ) : super(const ActiveOrdersState());

  final GetAssignedOrdersUsecase _getAssignedOrders;
  final RejectOrderUsecase _rejectOrder;
  final GetDispatchDetailUsecase _getDispatchDetail;
  final LocationBroadcastingService _locationBroadcastingService;

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

  // Same as loadAssignedOrders() but never emits isLoading: true — used for
  // socket-triggered refreshes so the dashboard list doesn't flash on every
  // order:status_update event.
  Future<void> silentReloadAssignedOrders() async {
    try {
      final orders = await _getAssignedOrders();
      _hasLoadedOnce = true;
      emit(state.copyWith(orders: orders, clearError: true));
    } catch (_) {
      // Keep showing the last known list on a silent-reload failure.
    }
  }

  // Adds an order built straight from a push notification payload — no API
  // round-trip, so it appears on the dashboard instantly. Guards against
  // showing the same order twice (e.g. a duplicate/retried notification).
  void addOrderFromNotification(AssignedOrderEntity order) {
    final exists = state.orders.any((o) => o.orderId == order.orderId);
    if (exists) {
      debugPrint('[DineOut NG Rider] Order already in list: ${order.orderId}');
      return;
    }
    emit(state.copyWith(orders: [order, ...state.orders]));
    debugPrint('[DineOut NG Rider] ✅ Order added from notification: ${order.orderId}');
  }

  Future<void> startDelivery(AssignedOrderEntity order) async {
    emit(state.copyWith(startingOrderId: order.orderId));

    // The dispatch endpoint is the richest source (preparationNote, full
    // items) — fetched on every tap. On failure fall back to the tapped
    // order's data; never block the delivery from starting.
    var resolvedOrder = order;
    try {
      resolvedOrder = await _getDispatchDetail(order.orderId);
    } catch (e) {
      debugPrint('[DineOut NG Rider] Dispatch fetch failed, using cached data: $e');
    }

    emit(
      state.copyWith(
        activeDeliveryOrder: resolvedOrder,
        clearStartingOrderId: true,
      ),
    );
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

  // Called on logout. This cubit is a GetIt singleton that outlives any one
  // rider's session — without this, the next rider to log in on the same app
  // process would inherit the previous rider's stale orders/active delivery,
  // which then leaks the wrong masterOrderId into location broadcasts.
  void reset() {
    _hasLoadedOnce = false;
    _locationBroadcastingService.updateMasterOrderId(null);
    emit(const ActiveOrdersState());
  }
}
