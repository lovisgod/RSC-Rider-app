import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/active_delivery_summary_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/earnings_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/rider_status_entity.dart';

class DashboardSummaryEntity extends Equatable {
  const DashboardSummaryEntity({
    required this.status,
    required this.earnings,
    required this.activeDelivery,
  });

  final RiderStatusEntity status;
  final EarningsEntity earnings;
  final ActiveDeliverySummaryEntity? activeDelivery;

  DashboardSummaryEntity copyWith({
    RiderStatusEntity? status,
    EarningsEntity? earnings,
    ActiveDeliverySummaryEntity? activeDelivery,
  }) =>
      DashboardSummaryEntity(
        status: status ?? this.status,
        earnings: earnings ?? this.earnings,
        activeDelivery: activeDelivery ?? this.activeDelivery,
      );

  @override
  List<Object?> get props => [status, earnings, activeDelivery];
}
