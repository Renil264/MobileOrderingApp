// lib/core/user_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'global_user.dart';

class UserStorage {
  static const _keyId         = 'user_id';
  static const _keyName       = 'user_name';
  static const _keyEmail      = 'user_email';
  static const _keyFcmToken   = 'fcm_token';
  static const _keyProvider   = 'login_provider';
  static const _keyPhotoUrl   = 'photo_url';
  static const _keyIsLoggedIn = 'is_logged_in';

  /// Save user after normal login.
  static Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool('isLoggedIn', true);

    // Use setUser() — no public setters on GlobalUser
    await GlobalUser.setUser(id: id, name: name, email: email);
  }

  /// Save user after social login.
  static Future<void> saveSocialUser({
    required int id,
    required String name,
    required String email,
    required String fcmToken,
    required String provider,
    required String uuid,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyFcmToken, fcmToken);
    await prefs.setString(_keyProvider, provider);
    await prefs.setString(_keyPhotoUrl, photoUrl ?? '');
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool('isLoggedIn', true);

    // Use setUser() — no public setters on GlobalUser
    await GlobalUser.setUser(id: id, name: name, email: email);
  }

  /// Load persisted user into GlobalUser on app start.
  static Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id    = prefs.getInt(_keyId) ?? 0;
    final name  = prefs.getString(_keyName) ?? '';
    final email = prefs.getString(_keyEmail) ?? '';

    // Only populate if we actually have data
    if (id != 0) {
      await GlobalUser.setUser(id: id, name: name, email: email);
    }
  }

  /// Returns true if either login key is set.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getBool(_keyIsLoggedIn) ?? false;
    final b = prefs.getBool('isLoggedIn') ?? false;
    return a || b;
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id':         prefs.getInt(_keyId),
      'name':       prefs.getString(_keyName),
      'email':      prefs.getString(_keyEmail),
      'fcmToken':   prefs.getString(_keyFcmToken),
      'provider':   prefs.getString(_keyProvider),
      'photoUrl':   prefs.getString(_keyPhotoUrl),
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
    };
  }

  static Future<void> saveConcessionId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('concession_id', id);
  }

  static Future<int?> getConcessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('concession_id');
  }

  /// Clear all keys on logout.
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFcmToken);
    await prefs.remove(_keyProvider);
    await prefs.remove(_keyPhotoUrl);
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.setBool('isLoggedIn', false);

    // Use clear() — no public setters on GlobalUser
    await GlobalUser.clear();
  }
}