// lib/core/global_user.dart
// Persists login state to SharedPreferences so the app can decide
// on startup whether to show LoginForm or HomePage.
//
// Key "isLoggedIn" = true  → user closed app without logging out → go to HomePage
// Key "isLoggedIn" = false → user logged out explicitly          → go to LoginForm

import 'package:shared_preferences/shared_preferences.dart';

class GlobalUser {
  static int _id = 0;
  static String _name = '';
  static String _email = '';

  static int get id => _id;
  static String get name => _name;
  static String get email => _email;

  // ── Set user after successful login ────────────────────────────
  static Future<void> setUser({
    required int id,
    required String name,
    required String email,
  }) async {
    _id = id;
    _name = name;
    _email = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  // ── Load persisted user on app start ───────────────────────────
  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _id    = prefs.getInt('userId') ?? 0;
    _name  = prefs.getString('userName') ?? '';
    _email = prefs.getString('userEmail') ?? '';
  }

  // ── Check if user was logged in when app was last closed ───────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ── Clear on explicit logout ────────────────────────────────────
  // Sets isLoggedIn = false so next cold start goes to LoginForm.
  static Future<void> clear() async {
    _id    = 0;
    _name  = '';
    _email = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }
}