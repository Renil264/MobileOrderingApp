// lib/core/global_concession.dart
// Stores the currently selected concessionName and categoryId
// both in-memory and in SharedPreferences so they're accessible anywhere.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalConcession {
  static String _name = '';
  static int _categoryId = 0;

  // ── Getters ──────────────────────────────────────────────────────
  static String get name => _name;
  static int get categoryId => _categoryId;

  // ── Set & persist both together ──────────────────────────────────
  static Future<void> set({
    required String concessionName,
    required int categoryId,
  }) async {
    _name = concessionName;
    _categoryId = categoryId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('concessionName', concessionName);
    await prefs.setInt('concessionCategoryId', categoryId);
  }

  // ── Set only concession name (when category isn't changing) ──────
  static Future<void> setName(String concessionName) async {
    _name = concessionName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('concessionName', concessionName);
  }

  // ── Set only category id ─────────────────────────────────────────
  static Future<void> setCategoryId(int id) async {
    _categoryId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('concessionCategoryId', id);
  }

  // ── Load from SharedPreferences on app start ─────────────────────
  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('concessionName') ?? '';
    _categoryId = prefs.getInt('concessionCategoryId') ?? 0;
  }

  // ── Clear ────────────────────────────────────────────────────────
  static Future<void> clear() async {
    _name = '';
    _categoryId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('concessionName');
    await prefs.remove('concessionCategoryId');
  }
}