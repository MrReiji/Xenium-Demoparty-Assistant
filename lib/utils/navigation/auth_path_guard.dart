import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  final _storage = GetIt.I<FlutterSecureStorage>();

  /// Checks if the current session is valid.
  Future<bool> isSessionValid() async {
    final sessionCookie = await _storage.read(key: 'session_cookie');
    final expiryString = await _storage.read(key: 'cookie_expiry');

    if (sessionCookie == null || expiryString == null) {
      // No session or expiry found, session is invalid.
      return false;
    }

    final expiryDate = DateTime.parse(expiryString);
    if (expiryDate.isBefore(DateTime.now())) {
      // Session expired, clear storage.
      await clearSession();
      return false;
    }

    // Session is valid.
    return true;
  }

  /// Clears session data from secure storage.
  Future<void> clearSession() async {
    await _storage.delete(key: 'session_cookie');
    await _storage.delete(key: 'cookie_expiry');
    await _storage.delete(key: 'user_name'); // Clear additional data if needed.
  }

  /// Redirects to login if no valid session is found.
  Future<String?> redirect(GoRouterState state) async {
    final isValid = await isSessionValid();
    if (!isValid) {
      return '/authorization'; // Redirect to login if session is invalid.
    }
    return null; // Allow access if session is valid.
  }
}
