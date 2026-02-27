// lib/features/auth/data/datasources/concession_by_item_remote_datasource.dart
//
// GET /concessions-by-category/{marketId}/{categoryId}
// Response: [ { "concessionId": 8601, "concessionName": "Snack Shack" }, ... ]

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/features/auth/data/model/concession_by_item_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


abstract class ConcessionByItemRemoteDataSource {
  Future<List<ConcessionByItemModel>> getConcessionsByCategory({
    required int marketId,
    required int categoryId,
  });
}

class ConcessionByItemRemoteDataSourceImpl
    implements ConcessionByItemRemoteDataSource {
  final http.Client client;

  ConcessionByItemRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ConcessionByItemModel>> getConcessionsByCategory({
    required int marketId,
    required int categoryId,
  }) async {
    try {
      if (marketId == 0) {
        throw Exception(
            'marketId is 0 — GlobalMarketData not populated. '
            'Make sure the concessions endpoint was called first.');
      }

      final uri = Uri.parse(
        'http://192.168.10.144/ConcessionTracker/api/Users'
        '/concessions-by-category/$marketId/$categoryId',
      );

      print('══════════════════════════════════════');
      print('[ConcessionByCategory] GET $uri');
      print('  marketId   : $marketId');
      print('  categoryId : $categoryId');
      print('══════════════════════════════════════');

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print('[ConcessionByCategory] Status  : ${response.statusCode}');
      print('[ConcessionByCategory] Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(response.body) as List<dynamic>;

        final models = jsonList
            .map((e) => ConcessionByItemModel.fromJson(
                e as Map<String, dynamic>))
            .toList();

        // ── Persist ALL returned concessions to SharedPreferences ──
        // We save the full list as JSON so it can be retrieved anywhere.
        // Additionally save the FIRST result individually for quick access.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'concessionsByCategory_$categoryId',
          json.encode(jsonList),
        );

        if (models.isNotEmpty) {
          await prefs.setInt(
              'catConcessionId', models.first.concessionId);
          await prefs.setString(
              'catConcessionName', models.first.concessionName);
          print('[ConcessionByCategory] Saved first: '
              'id=${models.first.concessionId} '
              'name="${models.first.concessionName}"');
        }

        return models;
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ConcessionByCategory] SocketException: $e');
      throw Exception('Cannot reach server. Check network connection.');
    } on TimeoutException catch (e) {
      print('[ConcessionByCategory] Timeout: $e');
      throw Exception('Request timed out.');
    } catch (e) {
      print('[ConcessionByCategory] Error: $e');
      rethrow;
    }
  }
}