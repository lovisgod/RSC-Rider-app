abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // User
  static const String userMe = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';

  // Rider
  static const String riderProfile = '/rider/profile';
  static const String toggleAvailability = '/rider/availability';
  static const String earnings = '/rider/earnings';
  static const String documents = '/rider/documents';
  static const String recordRiderLocation = '/riders/locations';

  // Dispatch
  static const String dispatchRequests = '/dispatch/requests';
  static String acceptRequest(String id) => '/dispatch/requests/$id/accept';
  static String rejectRequest(String id) => '/dispatch/requests/$id/reject';

  // Delivery
  static const String orders = '/orders';
  static const String activeDelivery = '/deliveries/active';
  static String deliveryById(String id) => '/deliveries/$id';
  static String updateDeliveryStatus(String id) => '/deliveries/$id/status';
  static String updateRiderLocation(String id) => '/deliveries/$id/location';
  static String completeDelivery(String orderId) =>
      '/orders/$orderId/complete-delivery';

  // Rider assigned orders
  static const String assignedOrders = '/riders/me/assigned-orders';
  static String rejectAssignedOrder(String id) =>
      '/riders/me/assigned-orders/$id/reject';

  // History
  static const String riderDeliveries = '/riders/me/deliveries';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String deviceToken = '/notifications/device-token';
}
