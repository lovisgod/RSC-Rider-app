import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';

// Reacts to order:status_update events for the logged-in rider by silently
// refreshing the assigned-orders list — covers new assignments, cancellations,
// and completions without ever showing a loading flash on the dashboard.
class SocketEventHandler {
  SocketEventHandler(this._socketService, this._activeOrdersCubit);

  final SocketService _socketService;
  final ActiveOrdersCubit _activeOrdersCubit;

  void initialize() {
    _socketService.on('order:status_update', _onOrderStatusUpdate);
    _socketService.connectionStatus.addListener(_onConnectionStatusChanged);
  }

  // Fires on every false→true transition (first connect and reconnects).
  // Any status update emitted while the socket was down is gone for good —
  // refetch so the list can never stay stale after an outage.
  void _onConnectionStatusChanged() {
    if (_socketService.connectionStatus.value) {
      unawaited(_activeOrdersCubit.silentReloadAssignedOrders());
      debugPrint('[DineOut NG Rider Socket] Reconnected — resyncing assigned orders');
    }
  }

  void _onOrderStatusUpdate(dynamic data) {
    debugPrint('[DineOut NG Rider Socket] order:status_update received: $data');

    try {
      final payload = data as Map<String, dynamic>;
      final masterOrderId = payload['masterOrderId'] as String?;
      final status = payload['status'] as String?;
      final riderId = payload['riderId'] as String?;

      debugPrint(
        '[DineOut NG Rider Socket] Order: $masterOrderId Status: $status '
        'RiderId: $riderId',
      );

      switch (status?.toUpperCase()) {
        case 'READY':
        case 'OUT_FOR_DELIVERY':
          unawaited(_activeOrdersCubit.silentReloadAssignedOrders());
          debugPrint(
            '[DineOut NG Rider Socket] Reloading assigned orders due to status: '
            '$status',
          );
        case 'DELIVERED':
        case 'CANCELLED':
          unawaited(_activeOrdersCubit.silentReloadAssignedOrders());
          debugPrint(
            '[DineOut NG Rider Socket] Order completed/cancelled: $masterOrderId',
          );
        default:
          unawaited(_activeOrdersCubit.silentReloadAssignedOrders());
          debugPrint(
            '[DineOut NG Rider Socket] Unknown status: $status — reloading orders',
          );
      }
    } catch (e) {
      debugPrint('[DineOut NG Rider Socket] Error handling status update: $e');
    }
  }

  void dispose() {
    _socketService.connectionStatus.removeListener(_onConnectionStatusChanged);
    _socketService.off('order:status_update', _onOrderStatusUpdate);
  }
}
