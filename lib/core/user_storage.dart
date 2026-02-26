import 'package:shared_preferences/shared_preferences.dart';
import 'global_user.dart';

class UserStorage {
  static const _keyId = "user_id";
  static const _keyName = "user_name";
  static const _keyEmail = "user_email";
  static const _keyFcmToken = "fcm_token";
  static const _keyProvider = "login_provider";
  static const _keyPhotoUrl = "photo_url";
  static const _keyIsLoggedIn = "is_logged_in";

  /// Save user (for normal login)
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

    // also store globally
    GlobalUser.id = id;
    GlobalUser.name = name;
    GlobalUser.email = email;
  }

  /// Save user from social login
  static Future<void> saveSocialUser({
    required int id,
    required String name,
    required String email,
    required String fcmToken,
    required String provider,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyFcmToken, fcmToken);
    await prefs.setString(_keyProvider, provider);
    await prefs.setString(_keyPhotoUrl, photoUrl ?? "");
    await prefs.setBool(_keyIsLoggedIn, true);

    // also store globally
    GlobalUser.id = id;
    GlobalUser.name = name;
    GlobalUser.email = email;
  }

  /// Load user at app start
  static Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    GlobalUser.id = prefs.getInt(_keyId);
    GlobalUser.name = prefs.getString(_keyName);
    GlobalUser.email = prefs.getString(_keyEmail);
  }

  /// Get all user data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt(_keyId),
      'name': prefs.getString(_keyName),
      'email': prefs.getString(_keyEmail),
      'fcmToken': prefs.getString(_keyFcmToken),
      'provider': prefs.getString(_keyProvider),
      'photoUrl': prefs.getString(_keyPhotoUrl),
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
    };
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static const _keyConcessionId = "concession_id";

  static Future<void> saveConcessionId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyConcessionId, id);
  }

  static Future<int?> getConcessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyConcessionId);
  }

  /// Clear user (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFcmToken);
    await prefs.remove(_keyProvider);
    await prefs.remove(_keyPhotoUrl);
    await prefs.setBool(_keyIsLoggedIn, false);

    GlobalUser.clear();
  }
}