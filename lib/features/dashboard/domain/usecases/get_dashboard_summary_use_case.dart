import 'package:rsc_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:rsc_rider/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummaryEntity> call() async {
    final statusFuture = _repository.getStatus();
    final earningsFuture = _repository.getEarnings();
    final activeDeliveryFuture = _repository.getActiveDelivery();

    return DashboardSummaryEntity(
      status: await statusFuture,
      earnings: await earningsFuture,
      activeDelivery: await activeDeliveryFuture,
    );
  }
}
