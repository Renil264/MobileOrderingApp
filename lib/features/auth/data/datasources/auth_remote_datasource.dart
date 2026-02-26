import 'dart:convert';
import 'package:concession_tracker_ui/features/auth/data/model/user_model.dart';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {

    final response = await client.post(
      Uri.parse("http://192.168.10.144/ConcessionTracker/api/Users/register"), // change if needed
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phoneNumber, // API expects number
        "fcmToken": GlobalFCM.token, // ✅ fetch globally
      }),
    );

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return UserModel.fromJson(decoded);
    } else {
      throw Exception("Registration Failed: ${response.body}");
    }
  }
}