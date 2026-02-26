// lib/core/global_selected_item.dart
// Persists itemId, categoryId, and concessionId globally via SharedPreferences.
// Call GlobalSelectedItem.set(...) when a menu item is loaded/selected.
// Access anywhere via GlobalSelectedItem.itemId etc.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalSelectedItem {
  static int _itemId = 0;
  static int _categoryId = 0;
  static int _concessionId = 0;

  // ── Getters ────────────────────────────────────────────────────
  static int get itemId => _itemId;
  static int get categoryId => _categoryId;
  static int get concessionId => _concessionId;

  // ── Set all three together ─────────────────────────────────────
  static Future<void> set({
    required int itemId,
    required int categoryId,
    required int concessionId,
  }) async {
    _itemId = itemId;
    _categoryId = categoryId;
    _concessionId = concessionId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedItemId', itemId);
    await prefs.setInt('selectedCategoryId', categoryId);
    await prefs.setInt('selectedConcessionId', concessionId);
  }

  // ── Set only concessionId (on store page open) ─────────────────
  static Future<void> setConcessionId(int id) async {
    _concessionId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedConcessionId', id);
  }

  // ── Load from SharedPreferences on app start ───────────────────
  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _itemId = prefs.getInt('selectedItemId') ?? 0;
    _categoryId = prefs.getInt('selectedCategoryId') ?? 0;
    _concessionId = prefs.getInt('selectedConcessionId') ?? 0;
  }

  // ── Clear all ──────────────────────────────────────────────────
  static Future<void> clear() async {
    _itemId = 0;
    _categoryId = 0;
    _concessionId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedItemId');
    await prefs.remove('selectedCategoryId');
    await prefs.remove('selectedConcessionId');
  }
}