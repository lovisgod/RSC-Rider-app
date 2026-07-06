import 'package:rsc_rider/features/dashboard/domain/entities/active_delivery_summary_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/earnings_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/rider_status_entity.dart';

abstract interface class DashboardRepository {
  Future<RiderStatusEntity> getStatus();
  Future<RiderStatusEntity> setAvailability({required bool isOnline});
  Future<EarningsEntity> getEarnings();
  Future<ActiveDeliverySummaryEntity?> getActiveDelivery();
}
