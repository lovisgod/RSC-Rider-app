import 'package:rsc_rider/features/delivery/domain/entities/assigned_item_entity.dart';

class AssignedOutletEntity {
  const AssignedOutletEntity({
    required this.subOrderId,
    required this.outletId,
    required this.outletName,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupCode,
    required this.status,
    required this.items,
  });

  final String subOrderId;
  final String outletId;
  final String outletName;
  final String? pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupCode;
  final String status;
  final List<AssignedItemEntity> items;
}
