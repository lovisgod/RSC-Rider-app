import 'package:rsc_rider/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/active_delivery_summary_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/earnings_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/rider_status_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardRemoteDataSource _dataSource;

  @override
  Future<RiderStatusEntity> getStatus() async =>
      (await _dataSource.getStatus()).toEntity();

  @override
  Future<RiderStatusEntity> setAvailability({required bool isOnline}) async =>
      (await _dataSource.setAvailability(isOnline)).toEntity();

  @override
  Future<EarningsEntity> getEarnings() async =>
      (await _dataSource.getEarnings()).toEntity();

  @override
  Future<ActiveDeliverySummaryEntity?> getActiveDelivery() async =>
      (await _dataSource.getActiveDelivery())?.toEntity();
}
