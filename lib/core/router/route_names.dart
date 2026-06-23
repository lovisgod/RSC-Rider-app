abstract final class RouteNames {
  // Public — no auth required
  static const String splash = '/';
  static const String login = '/login';

  // Shell tabs (require auth)
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Full-screen flows (require auth, no bottom nav)
  static const String incomingRequest = '/dispatch/request';
  static const String activeDelivery = '/delivery/active';

  // Profile sub-routes
  static const String editProfile = '/profile/edit';
  static const String documents = '/profile/documents';
}
