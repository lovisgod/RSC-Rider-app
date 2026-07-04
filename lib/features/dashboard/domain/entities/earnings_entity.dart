import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  const EarningsEntity({
    required this.today,
    required this.week,
    required this.todayDeliveries,
    required this.totalDeliveries,
  });

  final double today;
  final double week;
  final int todayDeliveries;
  final int totalDeliveries;

  @override
  List<Object> get props => [today, week, todayDeliveries, totalDeliveries];
}
