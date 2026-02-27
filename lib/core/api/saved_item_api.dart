import 'dart:convert';
import 'package:concession_tracker_ui/core/models/saved_items_model.dart';
import 'package:http/http.dart' as http;

class SavedItemsService {
  static const String baseUrl = 'http://192.168.10.144/ConcessionTracker/api';

  /// Fetches saved items for a specific user and market
  /// 
  /// [marketId] - The market ID
  /// [userId] - The user ID
  /// 
  /// Returns a list of [SavedItemModel] or throws an exception
  Future<List<SavedItemModel>> getSavedItems({
    required int marketId,
    required int userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/Users/saved-items/$marketId/$userId');
      
      print('═══════════════════════════════════════');
      print('[SavedItemsService] Fetching saved items...');
      print('URL: $url');
      print('marketId: $marketId, userId: $userId');
      print('═══════════════════════════════════════');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('═══════════════════════════════════════');
      print('[SavedItemsService] Response Status: ${response.statusCode}');
      print('[SavedItemsService] Response Body: ${response.body}');
      print('═══════════════════════════════════════');

      if (response.statusCode == 200) {
        // Decode the response body
        final dynamic decodedBody = json.decode(response.body);
        
        // Check if the response is a List or a Map
        if (decodedBody is List) {
          // Direct list of items
          return decodedBody
              .map((json) => SavedItemModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (decodedBody is Map<String, dynamic>) {
          // Check if it's wrapped in an object with a data field
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            final List<dynamic> jsonList = decodedBody['data'];
            return jsonList
                .map((json) => SavedItemModel.fromJson(json as Map<String, dynamic>))
                .toList();
          } else if (decodedBody.containsKey('items') && decodedBody['items'] is List) {
            final List<dynamic> jsonList = decodedBody['items'];
            return jsonList
                .map((json) => SavedItemModel.fromJson(json as Map<String, dynamic>))
                .toList();
          } else if (decodedBody.containsKey('message')) {
            // API returned an error message in a Map format
            final message = decodedBody['message'] ?? 'Unknown error occurred';
            throw Exception(message);
          } else {
            // Unknown Map structure
            throw Exception(
              'Unexpected response format: Expected a list or a data wrapper, got a Map with keys: ${decodedBody.keys.join(", ")}',
            );
          }
        } else {
          throw Exception('Unexpected response type: ${decodedBody.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        // No saved items found
        return [];
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request. Please check the market ID and user ID.');
      } else {
        // Try to parse error message from response
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            throw Exception(errorBody['message']);
          }
        } catch (_) {
          // If parsing fails, use generic error
        }
        throw Exception(
          'Failed to load saved items. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('═══════════════════════════════════════');
      print('[SavedItemsService] Network Error: $e');
      print('═══════════════════════════════════════');
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      print('═══════════════════════════════════════');
      print('[SavedItemsService] ERROR: $e');
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

  /// Unsaves an item for the user (removes from favorites)
  /// 
  /// [concessionId] - The concession ID
  /// [itemId] - The item ID to unsave
  /// [customerId] - The customer/user ID
  /// 
  /// Returns a success message or throws an exception
  Future<String> unsaveItem({
    required int concessionId,
    required int itemId,
    required int customerId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/Users/unsave-item');

      final requestBody = {
        'concessionId': concessionId,
        'itemId': itemId,
        'customerId': customerId,
      };

      print('═══════════════════════════════════════');
      print('[SavedItemsService] Unsaving item...');
      print('URL: $url');
      print('Request Body: $requestBody');
      print('═══════════════════════════════════════');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Request timeout. Please check your internet connection.',
          );
        },
      );

      print('═══════════════════════════════════════');
      print('[SavedItemsService] Response Status: ${response.statusCode}');
      print('[SavedItemsService] Response Body: ${response.body}');
      print('═══════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        final message = decodedBody['message'] ?? 'Item unsaved successfully';
        return message;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        final message = decodedBody['message'] ?? 'Invalid request';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Item not found or already unsaved.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          if (errorBody.containsKey('message')) {
            throw Exception(errorBody['message']);
          }
        } catch (_) {
          // If parsing fails, use generic error
        }
        throw Exception(
          'Failed to unsave item. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('═══════════════════════════════════════');
      print('[SavedItemsService] Network Error: $e');
      print('═══════════════════════════════════════');
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      print('═══════════════════════════════════════');
      print('[SavedItemsService] ERROR: $e');
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
}