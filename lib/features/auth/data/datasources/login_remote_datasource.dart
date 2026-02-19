import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/login_entity.dart';

class LoginRemoteDatasource {
  final String baseUrl =
      "http://192.168.10.144/ConcessionTracker/api/Users/login";

  Future<LoginEntity> login({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "fcmToken": fcmToken,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["message"] == "success") {
      return LoginEntity(
        message: data["message"] ?? "",
        userId: data["usr_int_usrid"] ?? 0,
        name: data["usr_vch_name"] ?? "",
      );
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }
}
