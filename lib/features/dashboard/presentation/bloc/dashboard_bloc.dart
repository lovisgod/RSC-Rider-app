import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/mock/mock_dashboard.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:rsc_rider/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:rsc_rider/features/profile/domain/usecases/get_rider_profile_usecase.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required this._localStorage,
    required this._locationService,
    required this._locationBroadcastingService,
    required this._getRiderProfile,
  }) : super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardAvailabilityToggled>(_onAvailabilityToggled);
    on<DashboardLocationUpdated>(_onLocationUpdated);
  }

  final LocalStorage _localStorage;
  final LocationService _locationService;
  final LocationBroadcastingService _locationBroadcastingService;
  final GetRiderProfileUsecase _getRiderProfile;
  StreamSubscription? _positionSubscription;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final riderName = await _resolveRiderName();
      final wasOnline = await _localStorage.getOnlineStatus();
      emit(
        DashboardLoaded(
          riderName: riderName,
          riderInitials: _initialsOf(riderName),
          isOnline: wasOnline,
          nearbyKitchens: wasOnline ? MockDashboard.nearbyKitchens : const [],
          isLoadingLocation: true,
        ),
      );
      if (wasOnline) {
        final activeOrderId = await _localStorage.getActiveMasterOrderId();
        await _locationBroadcastingService.startBroadcasting(
          masterOrderId: activeOrderId,
        );
      }
      await _startLocationTracking(emit);
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onAvailabilityToggled(
    DashboardAvailabilityToggled event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded) return;

    await _localStorage.saveOnlineStatus(event.isOnline);

    if (event.isOnline) {
      await _locationBroadcastingService.startBroadcasting(
        masterOrderId: null,
      );
    } else {
      _locationBroadcastingService.stopBroadcasting();
    }

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

  // Fetches the rider's real name from the profile endpoint and caches it
  // locally so the greeting still has something to show if a later refetch
  // (e.g. after an app restart with a flaky connection) fails.
  Future<String> _resolveRiderName() async {
    try {
      final profile = await _getRiderProfile();
      await _localStorage.saveRiderName(profile.name);
      return profile.name;
    } catch (_) {
      return await _localStorage.getRiderName() ?? 'Rider';
    }
  }

  // First letter of each word in the name, max 2 characters.
  String _initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _locationBroadcastingService.stopBroadcasting();
    return super.close();
  }
}
