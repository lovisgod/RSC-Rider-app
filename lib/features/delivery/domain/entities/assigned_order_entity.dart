import 'package:rsc_rider/features/delivery/domain/entities/assigned_outlet_entity.dart';

class AssignedOrderEntity {
  const AssignedOrderEntity({
    required this.orderId,
    required this.status,
    required this.deliveryCodeRequired,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.customerId,
    required this.riderId,
    required this.outlets,
  });

  final String orderId;
  final String status;
  final bool deliveryCodeRequired;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String customerId;
  final String riderId;
  final List<AssignedOutletEntity> outlets;

  String get shortOrderId => orderId.length >= 8
      ? '#${orderId.substring(orderId.length - 8).toUpperCase()}'
      : '#${orderId.toUpperCase()}';

  String get allItemsSummary => outlets
      .expand((outlet) => outlet.items)
      .map((item) => item.displayName)
      .join(', ');

  int get totalItems => outlets
      .expand((outlet) => outlet.items)
      .fold(0, (sum, item) => sum + item.quantity);
}
