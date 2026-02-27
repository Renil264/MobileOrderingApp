import 'dart:convert';
import 'package:concession_tracker_ui/core/models/saved_item_model.dart';
import 'package:http/http.dart' as http;


class SaveItemService {
  static const String baseUrl = 'http://192.168.10.144/ConcessionTracker/api';

  /// Saves an item to user's favorites
  /// 
  /// Returns a [SaveItemResponse] with success message or throws an exception
  Future<SaveItemResponse> saveItem(SaveItemRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/Users/save-item');
      
      print('═══════════════════════════════════════');
      print('[SaveItemService] Saving item...');
      print('URL: $url');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('═══════════════════════════════════════');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('═══════════════════════════════════════');
      print('[SaveItemService] Response Status: ${response.statusCode}');
      print('[SaveItemService] Response Body: ${response.body}');
      print('═══════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return SaveItemResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request. Please check the item details.');
      } else if (response.statusCode == 409) {
        // Item might already be saved
        throw Exception('Item is already saved.');
      } else {
        throw Exception(
          'Failed to save item. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('═══════════════════════════════════════');
      print('[SaveItemService] ERROR: $e');
      print('═══════════════════════════════════════');
      
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        rethrow;
      }
    }
  }


  Future<void> unsaveItem(request, {
    required int customerId,
    required int itemId,
  }) async {

    print('═══════════════════════════════════════');
    print('[SaveItemService] Unsave not implemented yet');
    print('customerId: $customerId, itemId: $itemId');
    print('═══════════════════════════════════════');
  }
}