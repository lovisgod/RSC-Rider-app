import 'package:rsc_rider/features/delivery/data/models/assigned_outlet_model.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';

class AssignedOrderModel {
  const AssignedOrderModel({
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

  factory AssignedOrderModel.fromJson(Map<String, dynamic> json) =>
      AssignedOrderModel(
        orderId: json['orderId'] as String,
        status: json['status'] as String,
        deliveryCodeRequired: json['deliveryCodeRequired'] as bool,
        deliveryAddress: json['deliveryAddress'] as String,
        deliveryLatitude: (json['deliveryLatitude'] as num).toDouble(),
        deliveryLongitude: (json['deliveryLongitude'] as num).toDouble(),
        customerId: json['customerId'] as String,
        riderId: json['riderId'] as String,
        outlets: (json['outlets'] as List<dynamic>? ?? [])
            .map((outlet) => AssignedOutletModel.fromJson(
                  Map<String, dynamic>.from(outlet as Map),
                ))
            .toList(),
      );

  final String orderId;
  final String status;
  final bool deliveryCodeRequired;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String customerId;
  final String riderId;
  final List<AssignedOutletModel> outlets;

  AssignedOrderEntity toEntity() => AssignedOrderEntity(
        orderId: orderId,
        status: status,
        deliveryCodeRequired: deliveryCodeRequired,
        deliveryAddress: deliveryAddress,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        customerId: customerId,
        riderId: riderId,
        outlets: outlets.map((outlet) => outlet.toEntity()).toList(),
      );
}
