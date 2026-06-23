import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:rsc_rider/core/utils/logger.dart';

// Top-level — Workmanager runs this in a separate isolate.
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == BackgroundLocationService.taskName) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        // TODO(Phase 5+): inject DioClient and POST position to backend.
        debugPrint(
          '[BGLocation] ${position.latitude}, ${position.longitude}',
        );
      } catch (e) {
        debugPrint('[BGLocation] Error: $e');
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

abstract final class BackgroundLocationService {
  static const String taskName = 'rsc_rider_location_update';
  static const String _uniqueName = 'background_location_update';

  // Call once from main() before runApp().
  static Future<void> initialize() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    appLogger.i('[BGLocation] Workmanager initialised');
  }

  // Starts a periodic background location push.
  // Minimum interval on Android is 15 minutes (OS-enforced).
  static Future<void> startTracking() async {
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      taskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    appLogger.i('[BGLocation] Periodic tracking started');
  }

  static Future<void> stopTracking() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
    appLogger.i('[BGLocation] Periodic tracking stopped');
  }
}
