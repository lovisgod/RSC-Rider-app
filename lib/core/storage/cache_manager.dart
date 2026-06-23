import 'package:shared_preferences/shared_preferences.dart';

abstract final class CacheKeys {
  static const String isAvailable = 'is_available';
  static const String themeMode = 'theme_mode';
  static const String lastLatitude = 'last_lat';
  static const String lastLongitude = 'last_lng';
}

class AppCacheManager {
  const AppCacheManager(this._prefs);

  final SharedPreferences _prefs;

  // Rider availability — persisted so it survives app restarts
  bool get isAvailable => _prefs.getBool(CacheKeys.isAvailable) ?? false;

  Future<void> setAvailability(bool value) =>
      _prefs.setBool(CacheKeys.isAvailable, value);

  // Theme preference
  String? get themeMode => _prefs.getString(CacheKeys.themeMode);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(CacheKeys.themeMode, mode);

  // Last known rider location — used to pre-position the map on launch
  ({double lat, double lng})? get lastKnownLocation {
    final lat = _prefs.getDouble(CacheKeys.lastLatitude);
    final lng = _prefs.getDouble(CacheKeys.lastLongitude);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  Future<void> saveLastLocation(double lat, double lng) async {
    await _prefs.setDouble(CacheKeys.lastLatitude, lat);
    await _prefs.setDouble(CacheKeys.lastLongitude, lng);
  }

  // Generic access
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
