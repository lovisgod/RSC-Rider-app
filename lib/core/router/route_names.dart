abstract final class RouteNames {
  // Public — no auth required
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Shell tabs (require auth)
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Full-screen flows (require auth, no bottom nav)
  static const String incomingRequest = '/dispatch/request';
  static const String activeDelivery = '/active-delivery';
  static const String completeDelivery = '/complete-delivery';

  // Profile sub-routes
  static const String editProfile = '/profile/edit';
  static const String documents = '/profile/documents';
  static const String changePassword = '/profile/change-password';
}
