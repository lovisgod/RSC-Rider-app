import 'package:equatable/equatable.dart';
import 'package:rsc_rider/core/mock/mock_dashboard.dart';

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
  const DashboardLoaded({
    required this.riderName,
    required this.riderInitials,
    this.isOnline = false,
    required this.todayEarnings,
    required this.todayDeliveries,
    required this.weekEarnings,
    required this.weekDeliveries,
    this.nearbyKitchens = const [],
    this.riderLatitude,
    this.riderLongitude,
    this.isLoadingLocation = false,
    this.locationError,
  });

  final String riderName;
  final String riderInitials;
  final bool isOnline;
  final double todayEarnings;
  final int todayDeliveries;
  final double weekEarnings;
  final int weekDeliveries;
  final List<MockKitchen> nearbyKitchens;
  final double? riderLatitude;
  final double? riderLongitude;
  final bool isLoadingLocation;
  final String? locationError;

  DashboardLoaded copyWith({
    String? riderName,
    String? riderInitials,
    bool? isOnline,
    double? todayEarnings,
    int? todayDeliveries,
    double? weekEarnings,
    int? weekDeliveries,
    List<MockKitchen>? nearbyKitchens,
    double? riderLatitude,
    double? riderLongitude,
    bool? isLoadingLocation,
    String? locationError,
    bool clearLocationError = false,
  }) =>
      DashboardLoaded(
        riderName: riderName ?? this.riderName,
        riderInitials: riderInitials ?? this.riderInitials,
        isOnline: isOnline ?? this.isOnline,
        todayEarnings: todayEarnings ?? this.todayEarnings,
        todayDeliveries: todayDeliveries ?? this.todayDeliveries,
        weekEarnings: weekEarnings ?? this.weekEarnings,
        weekDeliveries: weekDeliveries ?? this.weekDeliveries,
        nearbyKitchens: nearbyKitchens ?? this.nearbyKitchens,
        riderLatitude: riderLatitude ?? this.riderLatitude,
        riderLongitude: riderLongitude ?? this.riderLongitude,
        isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
        locationError:
            clearLocationError ? null : (locationError ?? this.locationError),
      );

  @override
  List<Object?> get props => [
        riderName,
        riderInitials,
        isOnline,
        todayEarnings,
        todayDeliveries,
        weekEarnings,
        weekDeliveries,
        nearbyKitchens,
        riderLatitude,
        riderLongitude,
        isLoadingLocation,
        locationError,
      ];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
