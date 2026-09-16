// Rider availability toggle — separate from DashboardRepository, which is the
// mock-era summary contract that is still unregistered in DI.
abstract interface class AvailabilityRepository {
  // Returns the backend-confirmed availability, which the caller must treat
  // as the source of truth (not the value it sent).
  Future<bool> setAvailability(bool isAvailable);
}
