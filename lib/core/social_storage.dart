// lib/core/api/social_login_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';

class SocialLoginService {
  static const String _baseUrl =
      'http://192.168.10.144/ConcessionTracker/api/Users/social-login';

  // ================= SOCIAL LOGIN API CALL =================
  Future<Map<String, dynamic>?> socialLogin({
    required String email,
    required String name,
    required String provider,
    required String providerToken,
    required String? photoUrl,
    required String fcmToken,
    required String uuid,
  }) async {
    try {
      final requestBody = {
        "email": email,
        "name": name,
        "provider": provider,
        "providerToken": providerToken,
        "photoUrl": photoUrl ?? "",
        "fcmToken": fcmToken,
        "uuid": uuid,
      };

      print('Social Login Request: $requestBody');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('Social Login Response Status: ${response.statusCode}');
      print('Social Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final int userId    = responseData['user_id'] ?? 0;
        final String uName  = responseData['name'] ?? name;

        // ── Step 1: Write isLoggedIn=true + core user fields ─────
        // GlobalUser.setUser() persists 'isLoggedIn'=true, 'userId',
        // 'userName', 'userEmail' to SharedPreferences in one call.
        // This is what SplashScreen._route() reads on next cold start
        // to decide whether to go to MainShellPage or LoginPage.
        await GlobalUser.setUser(
          id:    userId,
          name:  uName,
          email: email,
        );

        // ── Step 2: Write social-specific fields ─────────────────
        // saveSocialUser writes FCM token, provider, photo URL, and
        // also redundantly writes both isLoggedIn keys as a safety net.
        await UserStorage.saveSocialUser(
          id:       userId,
          name:     uName,
          email:    email,
          fcmToken: fcmToken,
          provider: provider,
          photoUrl: photoUrl,
          uuid:     uuid,
        );

        print('Social login saved — userId=$userId isLoggedIn=true');
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