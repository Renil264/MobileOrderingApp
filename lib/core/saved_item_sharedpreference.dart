import 'dart:convert';
import 'package:concession_tracker_ui/core/models/saved_items_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SavedItemsPreferences {
  static const String _savedItemsKey = 'saved_items_data';

  // Save saved items to SharedPreferences
  static Future<bool> saveSavedItems(List<SavedItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          items.map((item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      return await prefs.setString(_savedItemsKey, jsonString);
    } catch (e) {
      print('Error saving saved items: $e');
      return false;
    }
  }

  // Get saved items from SharedPreferences
  static Future<List<SavedItemModel>> getSavedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_savedItemsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => SavedItemModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting saved items: $e');
      return [];
    }
  }

  // Clear saved items from SharedPreferences
  static Future<bool> clearSavedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_savedItemsKey);
    } catch (e) {
      print('Error clearing saved items: $e');
      return false;
    }
  }

  // Check if saved items exist in SharedPreferences
  static Future<bool> hasSavedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_savedItemsKey);
    } catch (e) {
      print('Error checking saved items: $e');
      return false;
    }
  }
}