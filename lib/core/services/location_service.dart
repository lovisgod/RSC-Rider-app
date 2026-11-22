import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rsc_rider/core/utils/logger.dart';

class LocationService {
  // TODO(confirm): Confirm the required Android/iOS Always permission flow;
  // background updates are best-effort when only while-in-use is granted.
  // High-accuracy stream used during active deliveries.
  // distanceFilter: only emits after the rider moves at least 10 m.
  Stream<Position> get positionStream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );

  Stream<Position> get backgroundPositionStream => Geolocator.getPositionStream(
    locationSettings: _backgroundLocationSettings,
  );

  LocationSettings get _backgroundLocationSettings {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Delivery in progress',
          notificationText:
              'Your location is shared to update delivery progress.',
          enableWakeLock: true,
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        activityType: ActivityType.automotiveNavigation,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25,
    );
  }

  Future<Position> getCurrentPosition({Duration? timeLimit}) =>
      Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );

  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }

    appLogger.i('[Location] Permission granted: $permission');
    if (permission == LocationPermission.whileInUse) {
      return LocationPermissionStatus.grantedWhileInUse;
    }
    return LocationPermissionStatus.granted;
  }

  Future<bool> get isServiceEnabled => Geolocator.isLocationServiceEnabled();

  // Opens the device location settings screen.
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  // Opens this app's OS settings screen (e.g. to grant a denied permission).
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

enum LocationPermissionStatus {
  granted,
  grantedWhileInUse,
  denied,
  deniedForever,
  serviceDisabled,
}
