abstract interface class RiderLocationRepository {
  Future<void> recordLocation(
    double latitude,
    double longitude, {
    String? masterOrderId,
  });
}

/// Thrown when the location endpoint responds 429. [retryAfter] is parsed
/// from the response's Retry-After header, falling back to a conservative
/// default when the header is absent.
class LocationRateLimitedException implements Exception {
  const LocationRateLimitedException(this.retryAfter);
  final Duration retryAfter;
}

/// Thrown when the server reports the active master order is no longer
/// assigned to this rider.
class LocationOrderNotAssignedException implements Exception {
  const LocationOrderNotAssignedException();
}

/// Thrown for transient failures (network errors, timeouts, 5xx) that are
/// safe to retry with backoff.
class LocationTransientException implements Exception {
  const LocationTransientException();
}

/// Thrown when the server rejects the submitted fix itself (e.g. invalid
/// coordinates) — retrying the same fix would not help.
class LocationRejectedException implements Exception {
  const LocationRejectedException();
}
