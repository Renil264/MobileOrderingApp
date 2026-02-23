// lib/features/auth/data/datasources/store_item_remote_datasource.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/features/auth/data/model/store_item_model.dart';
import 'package:http/http.dart' as http;


abstract class StoreItemRemoteDataSource {
  Future<List<StoreItemModel>> getStoreItems({
    required String concessionName,
    required int userId,
    required String userName,
    required String userEmail,
  });
}

class StoreItemRemoteDataSourceImpl implements StoreItemRemoteDataSource {
  final http.Client client;

  StoreItemRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StoreItemModel>> getStoreItems({
    required String concessionName,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final uri = Uri.parse(
          'http://192.168.10.144/ConcessionTracker/api/Users/items');

      final body = jsonEncode({
        'concessionName': concessionName,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
      });

      print('[StoreItems] POST $uri');
      print('[StoreItems] Body: $body');

      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('[StoreItems] Status: ${response.statusCode}');
      print('[StoreItems] Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((e) =>
                StoreItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[StoreItems] SocketException: $e');
      throw Exception('Cannot reach server. Check network connection.');
    } on TimeoutException catch (e) {
      print('[StoreItems] Timeout: $e');
      throw Exception('Request timed out.');
    } catch (e) {
      print('[StoreItems] Error: $e');
      rethrow;
    }
  }
}