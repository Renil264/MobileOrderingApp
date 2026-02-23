// lib/features/auth/data/datasources/concession_by_item_remote_datasource.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/features/auth/data/model/concession_by_item_model.dart';
import 'package:http/http.dart' as http;


abstract class ConcessionByItemRemoteDataSource {
  Future<List<ConcessionByItemModel>> getConcessionsByItem(int itemId);
}

class ConcessionByItemRemoteDataSourceImpl
    implements ConcessionByItemRemoteDataSource {
  final http.Client client;

  ConcessionByItemRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ConcessionByItemModel>> getConcessionsByItem(
      int itemId) async {
    try {
      print('[ConcessionByItem] Fetching for itemId: $itemId');

      final uri = Uri.parse(
        'http://192.168.10.144/ConcessionTracker/api/Users/concessions-by-item/$itemId',
      );

      print('[ConcessionByItem] Calling: $uri');

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print('[ConcessionByItem] Status: ${response.statusCode}');
      print('[ConcessionByItem] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((e) => ConcessionByItemModel.fromJson(
                e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ConcessionByItem] SocketException: $e');
      throw Exception('Cannot reach server. Check network connection.');
    } on TimeoutException catch (e) {
      print('[ConcessionByItem] Timeout: $e');
      throw Exception('Request timed out.');
    } catch (e) {
      print('[ConcessionByItem] Error: $e');
      rethrow;
    }
  }
}