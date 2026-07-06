abstract interface class RiderLocationRepository {
  Future<void> recordLocation(
    double latitude,
    double longitude, {
    String? masterOrderId,
  });
}
