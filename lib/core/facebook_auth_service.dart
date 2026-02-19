import 'package:concession_tracker_ui/core/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class FacebookAuthService {
  /// Login with Facebook (NO Firebase)
  static Future<bool> login() async {
        try {
      debugPrint('🔵 Facebook login started');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        debugPrint('❌ Facebook login cancelled or failed');
        return false;
      }

      final AccessToken accessToken = result.accessToken!;

      // Fetch user profile
      final userData = await FacebookAuth.instance.getUserData(
        fields: "id,name,email,picture.width(400)",
      );

      // 🔥 SAVE GLOBALLY (for backend)
      AuthSession.email = userData['email'];
      AuthSession.name = userData['name'];
      AuthSession.profilePhoto =
          userData['picture']?['data']?['url'];
      AuthSession.provider = 'facebook';
      AuthSession.providerToken = accessToken.tokenString;

      // ✅ DEBUG OUTPUT
      AuthSession.debugPrintSession();

      debugPrint('✅ Facebook login success');
      return true;
    }catch (e) {
      debugPrint('Facebook login error: $e');
      throw Exception('Facebook login failed');
    }
  }

  /// Logout
  static Future<void> logout() async {
    await FacebookAuth.instance.logOut();
    AuthSession.clear();
  }
}
