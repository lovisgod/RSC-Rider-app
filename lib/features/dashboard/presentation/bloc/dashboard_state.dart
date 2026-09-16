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
    this.nearbyKitchens = const [],
    this.riderLatitude,
    this.riderLongitude,
    this.isLoadingLocation = false,
    this.locationError,
    this.isTogglingAvailability = false,
    this.availabilityError,
  });

  final String riderName;
  final String riderInitials;
  final bool isOnline;
  final List<MockKitchen> nearbyKitchens;
  final double? riderLatitude;
  final double? riderLongitude;
  final bool isLoadingLocation;
  final String? locationError;
  // True while the availability PATCH is in flight — blocks double taps.
  final bool isTogglingAvailability;
  // One-shot: set when the availability call fails (after the optimistic
  // flip is reverted), cleared on the next toggle attempt.
  final String? availabilityError;

  DashboardLoaded copyWith({
    String? riderName,
    String? riderInitials,
    bool? isOnline,
    List<MockKitchen>? nearbyKitchens,
    double? riderLatitude,
    double? riderLongitude,
    bool? isLoadingLocation,
    String? locationError,
    bool clearLocationError = false,
    bool? isTogglingAvailability,
    String? availabilityError,
    bool clearAvailabilityError = false,
  }) =>
      DashboardLoaded(
        riderName: riderName ?? this.riderName,
        riderInitials: riderInitials ?? this.riderInitials,
        isOnline: isOnline ?? this.isOnline,
        nearbyKitchens: nearbyKitchens ?? this.nearbyKitchens,
        riderLatitude: riderLatitude ?? this.riderLatitude,
        riderLongitude: riderLongitude ?? this.riderLongitude,
        isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
        locationError:
            clearLocationError ? null : (locationError ?? this.locationError),
        isTogglingAvailability:
            isTogglingAvailability ?? this.isTogglingAvailability,
        availabilityError: clearAvailabilityError
            ? null
            : (availabilityError ?? this.availabilityError),
      );

  @override
  List<Object?> get props => [
        riderName,
        riderInitials,
        isOnline,
        nearbyKitchens,
        riderLatitude,
        riderLongitude,
        isLoadingLocation,
        locationError,
        isTogglingAvailability,
        availabilityError,
      ];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
