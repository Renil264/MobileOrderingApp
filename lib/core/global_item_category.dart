// lib/core/global_item_category.dart
// Stores the selected item category id and name both in-memory and SharedPreferences.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalItemCategory {
  static int _id = 0;
  static String _name = '';

  // ── Getters ──────────────────────────────────────────
  static int get id => _id;
  static String get name => _name;

  // ── Set & persist ────────────────────────────────────
  static Future<void> setCategory({
    required int id,
    required String name,
  }) async {
    _id = id;
    _name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedCategoryId', id);
    await prefs.setString('selectedCategoryName', name);
  }

  // ── Load from SharedPreferences on app start ─────────
  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('selectedCategoryId') ?? 0;
    _name = prefs.getString('selectedCategoryName') ?? '';
  }

  // ── Clear ─────────────────────────────────────────────
  static Future<void> clear() async {
    _id = 0;
    _name = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedCategoryId');
    await prefs.remove('selectedCategoryName');
  }
}