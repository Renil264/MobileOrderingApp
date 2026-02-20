import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ConcessionRemoteDataSource {
  Future<List<String>> getConcessions(String marketName);
}

class ConcessionRemoteDataSourceImpl implements ConcessionRemoteDataSource {
  final http.Client client;

  ConcessionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<String>> getConcessions(String marketName) async {
    final uri = Uri.parse(
      'http://192.168.10.144/ConcessionTracker/api/Users/concessions',
    ).replace(queryParameters: {'marketName': marketName});

    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => e.toString()).toList();
    } else {
      throw Exception(
        'Failed to load concessions. Status: ${response.statusCode}',
      );
    }
  }
}