import 'package:flutter/foundation.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';

// AuthNotifier is the single source of truth for auth state that go_router
// listens to via refreshListenable. AuthBloc (Phase 6) calls onLogin/onLogout
// after successful API responses, triggering an automatic route redirect.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._storage) {
    _init();
  }

  final LocalStorage _storage;

  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;

  // False while the initial secure-storage read is in progress.
  // The redirect returns null during this window so the splash screen shows.
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    _isAuthenticated = await _storage.hasValidSession;
    _isInitialized = true;
    notifyListeners();
  }

  void onLogin() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void onLogout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
