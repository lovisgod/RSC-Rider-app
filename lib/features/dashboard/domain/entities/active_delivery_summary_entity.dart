import 'package:equatable/equatable.dart';

class ActiveDeliverySummaryEntity extends Equatable {
  const ActiveDeliverySummaryEntity({
    required this.deliveryId,
    required this.statusLabel,
    required this.customerName,
    required this.pickupName,
  });

  final String deliveryId;
  final String statusLabel;
  final String customerName;
  final String pickupName;

  @override
  List<Object> get props => [deliveryId, statusLabel, customerName, pickupName];
}
