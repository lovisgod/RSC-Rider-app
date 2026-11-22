import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:rsc_rider/core/services/location_service.dart';
import 'package:rsc_rider/core/services/location_upload_throttle.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/delivery/domain/repositories/rider_location_repository.dart';
import 'package:rsc_rider/features/delivery/domain/usecases/record_rider_location_usecase.dart';

class LocationBroadcastingService {
  LocationBroadcastingService(
    this._recordLocation,
    this._locationService, {
    this._trackingMode = TrackingMode.appBased,
    this._onOrderNotAssigned,
  });

  final RecordRiderLocationUsecase _recordLocation;
  final LocationService _locationService;
  final TrackingMode _trackingMode;
  final Future<void> Function()? _onOrderNotAssigned;

  static const _heartbeatInterval = Duration(seconds: 15);
  static const _maxPendingAge = Duration(seconds: 60);
  static const _accuracyLimitMeters = 100.0;

  // TODO(confirm): Confirm the API's 12-per-60-second limit scope and whether
  // Retry-After is always present on 429 responses.
  // TODO(confirm): Confirm whether the POST may accept capturedAt; current
  // requests deliberately send only the latest fresh fix.
  final _random = Random();
  final _throttle = LocationUploadThrottle();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  Position? _pendingPosition;
  DateTime? _pendingSince;
  String? _activeMasterOrderId;
  DateTime? _retryAfter;
  int _consecutiveFailures = 0;
  bool _isRunning = false;
  bool _isSending = false;

  bool get isRunning => _isRunning;

  // TODO(confirm): Default to app-based tracking until the backend exposes a
  // rider tracking-mode flag or configuration endpoint.
  Future<void> startBroadcasting({String? masterOrderId}) async {
    if (_trackingMode == TrackingMode.hardwareGps) return;
    if (_isRunning) {
      _activeMasterOrderId = masterOrderId;
      return;
    }

    _activeMasterOrderId = masterOrderId;
    _isRunning = true;
    _positionSubscription = _locationService.backgroundPositionStream.listen(
      _queuePosition,
      onError: (Object error) => appLogger.w(
        '[LocationBroadcast] Position stream failed.',
        error: error,
      ),
    );
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      try {
        _queuePosition(
          await _locationService.getCurrentPosition(
            timeLimit: const Duration(seconds: 8),
          ),
        );
      } catch (error) {
        appLogger.w(
          '[LocationBroadcast] Heartbeat GPS read failed.',
          error: error,
        );
      }
    });

    try {
      _queuePosition(
        await _locationService.getCurrentPosition(
          timeLimit: const Duration(seconds: 8),
        ),
      );
    } catch (error) {
      appLogger.w('[LocationBroadcast] Initial GPS read failed.', error: error);
    }
  }

  void updateMasterOrderId(String? orderId) {
    if (orderId == null) {
      stopBroadcasting();
      return;
    }
    _activeMasterOrderId = orderId;
    unawaited(startBroadcasting(masterOrderId: orderId));
  }

  void stopBroadcasting() {
    _isRunning = false;
    _activeMasterOrderId = null;
    _pendingPosition = null;
    _pendingSince = null;
    _retryAfter = null;
    _throttle.reset();
    _consecutiveFailures = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = null;
  }

  void _queuePosition(Position position) {
    if (!_isRunning) return;
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude < -90 ||
        position.latitude > 90 ||
        position.longitude < -180 ||
        position.longitude > 180 ||
        (position.latitude == 0 && position.longitude == 0) ||
        position.accuracy > _accuracyLimitMeters) {
      appLogger.w(
        '[LocationBroadcast] Skipping invalid or low-accuracy GPS fix.',
      );
      return;
    }

    _pendingPosition = position;
    _pendingSince = DateTime.now();
    unawaited(_sendPendingPosition());
  }

  Future<void> _sendPendingPosition() async {
    if (!_isRunning || _isSending || _pendingPosition == null) return;
    final pendingSince = _pendingSince;
    final now = DateTime.now();
    if (pendingSince == null || now.difference(pendingSince) > _maxPendingAge) {
      _pendingPosition = null;
      _pendingSince = null;
      appLogger.w('[LocationBroadcast] Dropping stale pending GPS fix.');
      return;
    }

    final retryAfter = _retryAfter;
    final minimumWait = _throttle.waitBefore(now);
    final retryWait = retryAfter == null
        ? Duration.zero
        : retryAfter.difference(now);
    final wait = minimumWait > retryWait ? minimumWait : retryWait;
    if (wait > Duration.zero) {
      _scheduleRetry(wait);
      return;
    }

    final position = _pendingPosition!;
    _pendingPosition = null;
    _pendingSince = null;
    _throttle.recordAttempt(now);
    _isSending = true;
    try {
      await _recordLocation(
        position.latitude,
        position.longitude,
        masterOrderId: _activeMasterOrderId,
      );
      _retryAfter = null;
      _consecutiveFailures = 0;
      _throttle.recordSuccess();
      appLogger.d('[LocationBroadcast] Location uploaded successfully.');
    } on LocationRateLimitedException catch (error) {
      _retryAfter = DateTime.now().add(error.retryAfter);
      _throttle.recordRateLimit();
      _pendingPosition ??= position;
      _pendingSince ??= now;
      appLogger.w(
        '[LocationBroadcast] Rate limited; pausing location uploads.',
      );
      _scheduleRetry(error.retryAfter);
    } on LocationOrderNotAssignedException {
      _activeMasterOrderId = null;
      final refreshAssignedOrders = _onOrderNotAssigned;
      if (refreshAssignedOrders != null) {
        unawaited(refreshAssignedOrders());
      }
      appLogger.w(
        '[LocationBroadcast] Order is no longer assigned; omitting its ID.',
      );
    } on LocationTransientException {
      _pendingPosition ??= position;
      _pendingSince ??= now;
      _throttle.recordFailure();
      final exponent = min(_consecutiveFailures, 5);
      _consecutiveFailures++;
      final baseSeconds = min(60, 2 * (1 << exponent)).toInt();
      final delay =
          Duration(seconds: baseSeconds) +
          Duration(milliseconds: _random.nextInt(baseSeconds * 250 + 1));
      appLogger.w(
        '[LocationBroadcast] Temporary upload failure.',
      );
      _scheduleRetry(delay);
    } on LocationRejectedException {
      appLogger.w('[LocationBroadcast] Server rejected GPS fix; dropping it.');
    } catch (error) {
      appLogger.w('[LocationBroadcast] Location upload failed.', error: error);
    } finally {
      _isSending = false;
      if (_pendingPosition != null && _retryTimer == null) {
        unawaited(_sendPendingPosition());
      }
    }
  }

  void _scheduleRetry(Duration delay) {
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(_sendPendingPosition());
    });
  }
}

enum TrackingMode { appBased, hardwareGps }
