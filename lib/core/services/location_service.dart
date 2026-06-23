import 'package:geolocator/geolocator.dart';
import 'package:rsc_rider/core/utils/logger.dart';

class LocationService {
  // High-accuracy stream used during active deliveries.
  // distanceFilter: only emits after the rider moves at least 10 m.
  Stream<Position> get positionStream => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
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
    return LocationPermissionStatus.granted;
  }

  Future<bool> get isServiceEnabled => Geolocator.isLocationServiceEnabled();

  // Opens the device location settings screen.
  Future<bool> openSettings() => Geolocator.openLocationSettings();
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
