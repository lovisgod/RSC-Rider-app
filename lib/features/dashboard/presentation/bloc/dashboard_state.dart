import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/dashboard/domain/entities/dashboard_summary_entity.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(
    this.summary, {
    this.isUpdatingAvailability = false,
    this.availabilityError,
  });

  final DashboardSummaryEntity summary;
  final bool isUpdatingAvailability;
  final String? availabilityError;

  DashboardLoaded copyWith({
    DashboardSummaryEntity? summary,
    bool? isUpdatingAvailability,
    String? availabilityError,
    bool clearError = false,
  }) =>
      DashboardLoaded(
        summary ?? this.summary,
        isUpdatingAvailability:
            isUpdatingAvailability ?? this.isUpdatingAvailability,
        availabilityError:
            clearError ? null : (availabilityError ?? this.availabilityError),
      );

  @override
  List<Object?> get props => [summary, isUpdatingAvailability, availabilityError];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
