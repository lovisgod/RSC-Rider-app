import 'package:rsc_rider/features/dashboard/domain/entities/active_delivery_summary_entity.dart';

class ActiveDeliverySummaryModel {
  const ActiveDeliverySummaryModel({
    required this.deliveryId,
    required this.statusLabel,
    required this.customerName,
    required this.pickupName,
  });

  final String deliveryId;
  final String statusLabel;
  final String customerName;
  final String pickupName;

  factory ActiveDeliverySummaryModel.fromJson(Map<String, dynamic> json) =>
      ActiveDeliverySummaryModel(
        deliveryId: json['id'] as String,
        statusLabel: json['status'] as String? ?? '',
        customerName: json['customer_name'] as String? ?? '',
        pickupName: json['pickup_name'] as String? ?? '',
      );

  ActiveDeliverySummaryEntity toEntity() => ActiveDeliverySummaryEntity(
        deliveryId: deliveryId,
        statusLabel: statusLabel,
        customerName: customerName,
        pickupName: pickupName,
      );
}
