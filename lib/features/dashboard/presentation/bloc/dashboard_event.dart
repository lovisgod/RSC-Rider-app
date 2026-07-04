import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

final class DashboardAvailabilityToggled extends DashboardEvent {
  const DashboardAvailabilityToggled({required this.isOnline});

  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}
