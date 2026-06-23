abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Rider
  static const String riderProfile = '/rider/profile';
  static const String toggleAvailability = '/rider/availability';
  static const String earnings = '/rider/earnings';
  static const String documents = '/rider/documents';
  static const String registerFcmToken = '/rider/fcm-token';

  // Dispatch
  static const String dispatchRequests = '/dispatch/requests';
  static String acceptRequest(String id) => '/dispatch/requests/$id/accept';
  static String rejectRequest(String id) => '/dispatch/requests/$id/reject';

  // Delivery
  static const String activeDelivery = '/deliveries/active';
  static String deliveryById(String id) => '/deliveries/$id';
  static String updateDeliveryStatus(String id) => '/deliveries/$id/status';
  static String updateRiderLocation(String id) => '/deliveries/$id/location';
  static String completeDelivery(String id) => '/deliveries/$id/complete';

  // History
  static const String deliveryHistory = '/deliveries/history';
}
