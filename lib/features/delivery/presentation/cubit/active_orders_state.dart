import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';

class ActiveOrdersState extends Equatable {
  const ActiveOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isRejecting = false,
    this.rejectingOrderId,
    this.error,
    this.activeDeliveryOrder,
    this.startingOrderId,
  });

  final List<AssignedOrderEntity> orders;
  final bool isLoading;
  final bool isRejecting;
  final String? rejectingOrderId;
  final String? error;
  final AssignedOrderEntity? activeDeliveryOrder;

  // Order whose dispatch detail is being fetched after a "Start Delivery"
  // tap — drives the loading state on that order's card.
  final String? startingOrderId;

  ActiveOrdersState copyWith({
    List<AssignedOrderEntity>? orders,
    bool? isLoading,
    bool? isRejecting,
    String? rejectingOrderId,
    String? error,
    AssignedOrderEntity? activeDeliveryOrder,
    String? startingOrderId,
    bool clearError = false,
    bool clearRejectingOrderId = false,
    bool clearActiveDeliveryOrder = false,
    bool clearStartingOrderId = false,
  }) =>
      ActiveOrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        isRejecting: isRejecting ?? this.isRejecting,
        rejectingOrderId: clearRejectingOrderId
            ? null
            : (rejectingOrderId ?? this.rejectingOrderId),
        error: clearError ? null : (error ?? this.error),
        activeDeliveryOrder: clearActiveDeliveryOrder
            ? null
            : (activeDeliveryOrder ?? this.activeDeliveryOrder),
        startingOrderId: clearStartingOrderId
            ? null
            : (startingOrderId ?? this.startingOrderId),
      );

  @override
  List<Object?> get props => [
        orders,
        isLoading,
        isRejecting,
        rejectingOrderId,
        error,
        activeDeliveryOrder,
        startingOrderId,
      ];
}
