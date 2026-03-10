import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodModifiersService {
  static const String _baseUrl =
      'http://192.168.10.144/ConcessionTracker/api/Users/food-modifiers';

  // ── GET: Fetch food modifiers by concession ID ────────────────
  Future<List<FoodModifier>> getFoodModifiers(int concessionId) async {
    final url = '$_baseUrl/$concessionId';

    print('══════════════════════════════════════');
    print('[FoodModifiersService] GET $url');
    print('══════════════════════════════════════');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('[FoodModifiersService] Status: ${response.statusCode}');
      print('[FoodModifiersService] Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        
        final modifiers = jsonList
            .map((item) => FoodModifier.fromJson(item as Map<String, dynamic>))
            .toList();

        print('[FoodModifiersService] Loaded ${modifiers.length} modifiers');
        return modifiers;
      } else {
        throw Exception(
          'Failed to fetch food modifiers. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[FoodModifiersService] Error: $e');
      throw Exception('Error fetching food modifiers: $e');
    }
  }
}

// ── Food Modifier Model ────────────────────────────────────────
class FoodModifier {
  final int foodModifierId;
  final String foodModifierName;

  FoodModifier({
    required this.foodModifierId,
    required this.foodModifierName,
  });

  factory FoodModifier.fromJson(Map<String, dynamic> json) => FoodModifier(
        foodModifierId: json['foodModifierId'] ?? 0,
        foodModifierName: json['foodModifierName'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'foodModifierId': foodModifierId,
        'foodModifierName': foodModifierName,
      };

  @override
  String toString() => 'FoodModifier($foodModifierId: $foodModifierName)';
}