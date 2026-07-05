import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String riderId = 'rider_id';
  static const String riderName = 'rider_name';
  static const String riderRole = 'rider_role';
  static const String isOnline = 'rider_is_online';
  static const String activeMasterOrderId = 'active_master_order_id';
}

class LocalStorage {
  const LocalStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(StorageKeys.accessToken, accessToken);
    await write(StorageKeys.refreshToken, refreshToken);
  }

  Future<String?> getAccessToken() => read(StorageKeys.accessToken);

  Future<String?> getRefreshToken() => read(StorageKeys.refreshToken);

  Future<void> saveRiderId(String id) => write(StorageKeys.riderId, id);

  Future<String?> getRiderId() => read(StorageKeys.riderId);

  Future<void> saveRiderName(String name) => write(StorageKeys.riderName, name);

  Future<String?> getRiderName() => read(StorageKeys.riderName);

  Future<void> saveRiderRole(String role) => write(StorageKeys.riderRole, role);

  Future<String?> getRiderRole() => read(StorageKeys.riderRole);

  Future<void> saveOnlineStatus(bool isOnline) =>
      write(StorageKeys.isOnline, isOnline.toString());

  Future<bool> getOnlineStatus() async =>
      (await read(StorageKeys.isOnline)) == 'true';

  Future<void> saveActiveMasterOrderId(String id) =>
      write(StorageKeys.activeMasterOrderId, id);

  Future<String?> getActiveMasterOrderId() =>
      read(StorageKeys.activeMasterOrderId);

  Future<void> clearActiveMasterOrderId() =>
      delete(StorageKeys.activeMasterOrderId);

  // The rider auth session is cookie-based — the app never sees a token, so
  // rider_id (saved right after a successful login) is the session signal.
  Future<bool> get hasValidSession async {
    final riderId = await getRiderId();
    return riderId != null && riderId.isNotEmpty;
  }

  Future<void> clearSession() => deleteAll();
}
