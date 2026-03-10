// lib/core/global_market.dart

import 'package:shared_preferences/shared_preferences.dart';

class GlobalMarket {
  static String _marketName = '';

  static String get marketName => _marketName;

  // ── Set and persist market name ───────────────────────────────
  static Future<void> setMarket(String name) async {
    _marketName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('marketName', name);
  }

  // ── Load from SharedPreferences on app start ──────────────────
  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _marketName = prefs.getString('marketName') ?? '';
  }

  // ── Clear on logout ───────────────────────────────────────────
  static Future<void> clear() async {
    _marketName = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('marketName');
  }
}