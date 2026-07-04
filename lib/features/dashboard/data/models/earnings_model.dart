import 'package:rsc_rider/features/dashboard/domain/entities/earnings_entity.dart';

class EarningsModel {
  const EarningsModel({
    required this.today,
    required this.week,
    required this.todayDeliveries,
    required this.totalDeliveries,
  });

  final double today;
  final double week;
  final int todayDeliveries;
  final int totalDeliveries;

  factory EarningsModel.fromJson(Map<String, dynamic> json) => EarningsModel(
        today: (json['today'] as num?)?.toDouble() ?? 0,
        week: (json['week'] as num?)?.toDouble() ?? 0,
        todayDeliveries: (json['today_deliveries'] as num?)?.toInt() ?? 0,
        totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
      );

  EarningsEntity toEntity() => EarningsEntity(
        today: today,
        week: week,
        todayDeliveries: todayDeliveries,
        totalDeliveries: totalDeliveries,
      );
}
