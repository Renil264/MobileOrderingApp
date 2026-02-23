// lib/features/auth/data/datasources/item_by_category_remote_datasource.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/features/auth/data/model/items_by_categories_model.dart';
import 'package:http/http.dart' as http;


abstract class ItemByCategoryRemoteDataSource {
  Future<List<ItemByCategoryModel>> getItemsByCategory({
    required String concessionName,
    required int categoryId,
  });
}

class ItemByCategoryRemoteDataSourceImpl
    implements ItemByCategoryRemoteDataSource {
  final http.Client client;

  ItemByCategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ItemByCategoryModel>> getItemsByCategory({
    required String concessionName,
    required int categoryId,
  }) async {
    try {
      final uri = Uri.parse(
        'http://192.168.10.144/ConcessionTracker/api/Users/items-by-category',
      );

      final body = jsonEncode({
        'concessionName': concessionName,
        'categoryId': categoryId,
      });

      print('[ItemsByCategory] POST $uri');
      print('[ItemsByCategory] Body: $body');

      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('[ItemsByCategory] Status: ${response.statusCode}');
      print('[ItemsByCategory] Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((e) => ItemByCategoryModel.fromJson(
                e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ItemsByCategory] SocketException: $e');
      throw Exception('Cannot reach server. Check network connection.');
    } on TimeoutException catch (e) {
      print('[ItemsByCategory] Timeout: $e');
      throw Exception('Request timed out.');
    } catch (e) {
      print('[ItemsByCategory] Error: $e');
      rethrow;
    }
  }
}