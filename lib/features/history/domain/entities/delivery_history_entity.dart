import 'package:equatable/equatable.dart';
import 'package:rsc_rider/core/utils/formatters.dart';

class DeliveryHistoryEntity extends Equatable {
  const DeliveryHistoryEntity({
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

  String get displayDate => AppFormatters.shortDate(completedAt);

  String get displayTime => AppFormatters.time(completedAt);

  String get displayEarned => AppFormatters.currency(earned, decimals: false);

  String get shortOrderId {
    final id = masterOrderId.length > 8
        ? masterOrderId.substring(masterOrderId.length - 8)
        : masterOrderId;
    return '#${id.toUpperCase()}';
  }

  @override
  List<Object?> get props => [
        masterOrderId,
        deliveryMode,
        earned,
        currency,
        payoutStatus,
        completedAt,
      ];
}
