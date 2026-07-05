import 'dart:async';

import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/record_rider_location_usecase.dart';

// Broadcasts the rider's GPS position to the backend every 10 seconds while
// the rider is online. Runs for the lifetime of the app process (foreground)
// — a single long-lived Timer, started on go-online and stopped on
// go-offline or logout.
class LocationBroadcastingService {
  LocationBroadcastingService(this._recordLocation, this._locationService);

  final RecordRiderLocationUsecase _recordLocation;
  final LocationService _locationService;

  Timer? _broadcastTimer;
  String? _activeMasterOrderId;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> startBroadcasting({String? masterOrderId}) async {
    if (_isRunning) {
      _activeMasterOrderId = masterOrderId;
      return;
    }

    _activeMasterOrderId = masterOrderId;
    _isRunning = true;
    _broadcastTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _broadcastCurrentLocation(),
    );
    await _broadcastCurrentLocation();
  }

  // Called when the rider is assigned an order, or when a delivery completes.
  void updateMasterOrderId(String? orderId) {
    _activeMasterOrderId = orderId;
  }

  void stopBroadcasting() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _activeMasterOrderId = null;
    _isRunning = false;
  }

  Future<void> _broadcastCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      await _recordLocation(
        position.latitude,
        position.longitude,
        masterOrderId: _activeMasterOrderId,
      );
    } catch (e) {
      // Never throw — the timer must keep running regardless of a single
      // failed GPS read or network call.
      appLogger.w('[LocationBroadcast] Failed to broadcast location.', error: e);
    }
  }
}
