// lib/features/auth/data/datasources/item_category_remote_datasource.dart

// lib/features/auth/data/datasources/item_category_remote_datasource.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/features/auth/data/model/item_category_model.dart';
import 'package:http/http.dart' as http;


abstract class ItemCategoryRemoteDataSource {
  Future<List<ItemCategoryModel>> getItemCategories(String marketName);
}

class ItemCategoryRemoteDataSourceImpl
    implements ItemCategoryRemoteDataSource {
  final http.Client client;

  ItemCategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ItemCategoryModel>> getItemCategories(
      String marketName) async {
    try {
      // ── Debug logs — remove after fixing ─────────────────────
      print('[ItemCategory] marketName received: "$marketName"');

      if (marketName.trim().isEmpty) {
        throw Exception(
            'marketName is empty. GlobalMarket.marketName was not set before HomePage built.');
      }

      final uri = Uri.parse(
        'http://192.168.10.144/ConcessionTracker/api/Users/item-categories/$marketName',
      ).replace(queryParameters: {'marketName': marketName});

      print('[ItemCategory] Calling: $uri');

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print('[ItemCategory] Status: ${response.statusCode}');
      print('[ItemCategory] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((e) =>
                ItemCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ItemCategory] SocketException — server unreachable: $e');
      throw Exception('Cannot reach server. Check device is on same network.');
    } on TimeoutException catch (e) {
      print('[ItemCategory] Timeout: $e');
      throw Exception('Request timed out. Is the server running?');
    } catch (e) {
      print('[ItemCategory] Error: $e');
      rethrow;
    }
  }
}