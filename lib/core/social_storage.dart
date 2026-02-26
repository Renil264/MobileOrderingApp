import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:concession_tracker_ui/core/user_storage.dart';

class SocialLoginService {
  static const String _baseUrl =
      'http://192.168.10.144/ConcessionTracker/api/Users/social-login';

  // ================= SOCIAL LOGIN API CALL =================
  Future<Map<String, dynamic>?> socialLogin({
    required String email,
    required String name,
    required String provider, // 'google' or 'facebook'
    required String providerToken,
    required String? photoUrl,
    required String fcmToken,
  }) async {
    try {
      final requestBody = {
        "email": email,
        "name": name,
        "provider": provider,
        "providerToken": providerToken,
        "photoUrl": photoUrl ?? "",
        "fcmToken": fcmToken,
      };

      print('Social Login Request: $requestBody');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('Social Login Response Status: ${response.statusCode}');
      print('Social Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // ================= SAVE TO EXISTING USER STORAGE =================
        await UserStorage.saveSocialUser(
          id: responseData['user_id'] ?? 0,
          name: responseData['name'] ?? name,
          email: email,
          fcmToken: fcmToken,
          provider: provider,
          photoUrl: photoUrl,
        );

        print('User data saved to UserStorage');
        return responseData;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Social Login Exception: $e');
      rethrow;
    }
  }

  // ================= RETRIEVE DATA FROM USER STORAGE =================
  static Future<Map<String, dynamic>> getStoredUserData() async {
    return await UserStorage.getUserData();
  }

  // ================= CHECK IF USER IS LOGGED IN =================
  static Future<bool> isUserLoggedIn() async {
    return await UserStorage.isLoggedIn();
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    return await UserStorage.clearUser();
  }
}