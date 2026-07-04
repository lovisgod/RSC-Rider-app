import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/mock/mock_dashboard.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required this._localStorage,
    required this._locationService,
  }) : super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardAvailabilityToggled>(_onAvailabilityToggled);
    on<DashboardLocationUpdated>(_onLocationUpdated);
  }

  final LocalStorage _localStorage;
  final LocationService _locationService;
  StreamSubscription? _positionSubscription;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final riderName = await _localStorage.getRiderName() ?? 'Rider';
      emit(
        DashboardLoaded(
          riderName: riderName,
          riderInitials: _initialsOf(riderName),
          todayEarnings: MockDashboard.todayEarnings,
          todayDeliveries: MockDashboard.todayDeliveries,
          weekEarnings: MockDashboard.weekEarnings,
          weekDeliveries: MockDashboard.weekDeliveries,
          isLoadingLocation: true,
        ),
      );
      await _startLocationTracking(emit);
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded) return;

    emit(
      current.copyWith(
        todayEarnings: MockDashboard.todayEarnings,
        todayDeliveries: MockDashboard.todayDeliveries,
        weekEarnings: MockDashboard.weekEarnings,
        weekDeliveries: MockDashboard.weekDeliveries,
      ),
    );
  }

  Future<void> _onAvailabilityToggled(
    DashboardAvailabilityToggled event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded) return;

    emit(
      current.copyWith(
        isOnline: event.isOnline,
        nearbyKitchens:
            event.isOnline ? MockDashboard.nearbyKitchens : const [],
      ),
    );
  }

  void _onLocationUpdated(
    DashboardLocationUpdated event,
    Emitter<DashboardState> emit,
  ) {
    final current = state;
    if (current is! DashboardLoaded) return;

    emit(
      current.copyWith(
        riderLatitude: event.latitude,
        riderLongitude: event.longitude,
      ),
    );
  }

  Future<void> _startLocationTracking(Emitter<DashboardState> emit) async {
    final permission = await _locationService.checkAndRequestPermission();
    final current = state;
    if (current is! DashboardLoaded) return;

    if (permission != LocationPermissionStatus.granted) {
      emit(
        current.copyWith(
          isLoadingLocation: false,
          locationError: 'Location permission denied.',
        ),
      );
      return;
    }

    final position = await _locationService.getCurrentPosition();
    final withPosition = current.copyWith(
      riderLatitude: position.latitude,
      riderLongitude: position.longitude,
      isLoadingLocation: false,
      clearLocationError: true,
    );
    emit(withPosition);

    await _positionSubscription?.cancel();
    _positionSubscription = _locationService.positionStream.listen((position) {
      add(
        DashboardLocationUpdated(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    });
  }

  // First letter of each word in the name, max 2 characters.
  String _initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
