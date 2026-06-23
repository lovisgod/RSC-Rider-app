import 'package:app_links/app_links.dart';
import 'package:rsc_rider/core/utils/logger.dart';

class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  // Returns the URI that launched the app from a terminated state, if any.
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e) {
      appLogger.w('[DeepLink] Failed to get initial link: $e');
      return null;
    }
  }

  // Emits URIs while the app is running (foreground / background).
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  // Convenience initialiser — handles both initial and subsequent links.
  // Call from your root widget or app service and pass the link to go_router.
  Future<void> initialize(void Function(Uri uri) onLink) async {
    final initial = await getInitialLink();
    if (initial != null) {
      appLogger.i('[DeepLink] Initial link: $initial');
      onLink(initial);
    }

    linkStream.listen(
      (uri) {
        appLogger.i('[DeepLink] Incoming link: $uri');
        onLink(uri);
      },
      onError: (Object e) => appLogger.w('[DeepLink] Stream error: $e'),
    );
  }
}
