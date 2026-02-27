import 'package:shared_preferences/shared_preferences.dart';

class Ordno {
  static int? orderno;

  /// Set order number (memory + storage)
  static Future<void> set(int value) async {
    orderno = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("orderNo", value);
  }

  /// Restore order number from storage
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    orderno = prefs.getInt("orderNo");
  }

  /// Clear order number
  static Future<void> clear() async {
    orderno = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("orderNo");
  }
}