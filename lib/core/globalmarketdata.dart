// lib/core/global_market_data.dart
// Stores the marketId returned from the concessions API.
// Persisted in SharedPreferences so it's available app-wide.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalMarketData {
  static int _marketId = 0;

  static int get marketId => _marketId;

  static Future<void> setMarketId(int id) async {
    _marketId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('marketId', id);
  }

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _marketId = prefs.getInt('marketId') ?? 0;
  }

  static Future<void> clear() async {
    _marketId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('marketId');
  }
}