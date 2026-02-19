import 'dart:io';
import 'package:concession_tracker_ui/core/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: Platform.isIOS
          ? '607534108011-p05v91hks7g51haa23u4ugtjcmc7mtrc.apps.googleusercontent.com'
          : null,
    );
  }

  /// 🔐 GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Google Sign-In started');

      // Clear previous session
      await _googleSignIn.signOut();

      // Launch Google chooser
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ User cancelled Google Sign-In');
        return null;
      }

      debugPrint('✅ Google account selected');
      debugPrint('Email : ${googleUser.email}');
      debugPrint('Name  : ${googleUser.displayName}');
      debugPrint('Photo : ${googleUser.photoUrl}');

      // Get auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Missing Google ID Token');
      }

      // 🔥 SAVE GLOBALLY (for backend)
      AuthSession.email = googleUser.email;
      AuthSession.name = googleUser.displayName;
      AuthSession.profilePhoto = googleUser.photoUrl;
      AuthSession.provider = 'google';
      AuthSession.providerToken = googleAuth.idToken;

      AuthSession.debugPrintSession();

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Firebase sign-in
      final userCredential =
          await _auth.signInWithCredential(credential);

      debugPrint('🔥 Firebase login success');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  /// 🔓 SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    AuthSession.clear();
    debugPrint('👋 Signed out');
  }

  User? get currentUser => _auth.currentUser;
}
