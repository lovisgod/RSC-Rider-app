import 'package:rsc_rider/features/history/domain/entities/delivery_history_entity.dart';

class DeliveryHistoryModel {
  const DeliveryHistoryModel({
    required this.masterOrderId,
    required this.deliveryMode,
    required this.earned,
    required this.currency,
    required this.payoutStatus,
    required this.completedAt,
  });

  final String masterOrderId;
  final String deliveryMode;
  final double earned;
  final String currency;
  final String payoutStatus;
  final DateTime completedAt;

  factory DeliveryHistoryModel.fromJson(Map<String, dynamic> json) =>
      DeliveryHistoryModel(
        masterOrderId: json['masterOrderId'] as String,
        deliveryMode: json['deliveryMode'] as String,
        earned: (json['earnedMinor'] as num) / 100,
        currency: json['currency'] as String,
        payoutStatus: json['payoutStatus'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );

  DeliveryHistoryEntity toEntity() => DeliveryHistoryEntity(
        masterOrderId: masterOrderId,
        deliveryMode: deliveryMode,
        earned: earned,
        currency: currency,
        payoutStatus: payoutStatus,
        completedAt: completedAt,
      );
}
