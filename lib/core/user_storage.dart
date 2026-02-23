import 'package:shared_preferences/shared_preferences.dart';
import 'global_user.dart';

class UserStorage {
  static const _keyId = "user_id";
  static const _keyName = "user_name";
  static const _keyEmail = "user_email";

  /// Save user
  static Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance(); 

    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);

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

  /// Clear user (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);

    GlobalUser.clear();
  }
}
