// lib/features/auth/data/datasources/remote_datasource.dart
//
// GET /concessions?marketName=X
// New response shape:
// {
//   "marketId": 1,
//   "concessions": ["Store A", "Store B", ...]
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:http/http.dart' as http;

abstract class ConcessionRemoteDataSource {
  /// Returns a flat list of concession name strings.
  /// Saves marketId to GlobalMarketData as a side effect.
  Future<List<String>> getConcessions(String marketName);
}

class ConcessionRemoteDataSourceImpl implements ConcessionRemoteDataSource {
  final http.Client client;

  ConcessionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<String>> getConcessions(String marketName) async {
    try {
      if (marketName.trim().isEmpty) {
        throw Exception('marketName is empty — cannot fetch concessions.');
      }

      final uri = Uri.parse(
        'http://192.168.10.144/ConcessionTracker/api/Users/concessions',
      ).replace(queryParameters: {'marketName': marketName});

      print('[Concessions] GET $uri');

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print('[Concessions] Status: ${response.statusCode}');
      print('[Concessions] Body  : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(response.body) as Map<String, dynamic>;

        // ── Save marketId globally + to SharedPreferences ──────
        final int marketId = (jsonMap['marketId'] as num?)?.toInt() ?? 0;
        await GlobalMarketData.setMarketId(marketId);
        print('[Concessions] marketId saved: $marketId');

        // ── Extract concession name strings ────────────────────
        final List<dynamic> raw =
            jsonMap['concessions'] as List<dynamic>? ?? [];
        return raw.map((e) => e.toString()).toList();
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[Concessions] SocketException: $e');
      throw Exception('Cannot reach server. Check network connection.');
    } on TimeoutException catch (e) {
      print('[Concessions] Timeout: $e');
      throw Exception('Request timed out.');
    } catch (e) {
      print('[Concessions] Error: $e');
      rethrow;
    }
  }
}