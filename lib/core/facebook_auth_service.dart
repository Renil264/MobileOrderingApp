import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  /// Login with Facebook (NO Firebase)
  static Future<Map<String, dynamic>?> login() async {
    try {
      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        return null; // Cancelled or failed
      }

      // Fetch user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );

      return {
        'accessToken': result.accessToken?.tokenString,
        'user': userData,
      };
    } catch (e) {
      throw Exception('Facebook login failed');
    }
  }

  /// Logout
  static Future<void> logout() async {
    await FacebookAuth.instance.logOut();
  }
}
