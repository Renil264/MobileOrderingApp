import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    debugPrint('🔧 Initializing GoogleAuthService...');
    
    // Use serverClientId for iOS (Web Client ID from Firebase)
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      // ⚠️ ADD THIS: Use your Web Client ID from Firebase Console
      serverClientId: Platform.isIOS 
          ? '607534108011-p05v91hks7g51haa23u4ugtjcmc7mtrc.apps.googleusercontent.com' 
          : null,
    );
    
    debugPrint('✅ GoogleSignIn initialized');
  }

  Future<User?> signInWithGoogle() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 GOOGLE SIGN-IN STARTING');
    debugPrint('═══════════════════════════════════════');

    try {
      // Check Firebase
      debugPrint('[1/6] Checking Firebase...');
      final app = _auth.app;
      debugPrint('✅ Firebase: ${app.name}');

      // Sign out previous
      debugPrint('[2/6] Clearing session...');
      await _googleSignIn.signOut();

      // Launch sign-in
      debugPrint('[3/6] Launching Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ User cancelled');
        return null;
      }

      debugPrint('✅ Account: ${googleUser.email}');

      // Get tokens
      debugPrint('[4/6] Getting tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get tokens');
      }

      debugPrint('✅ Tokens received');

      // Create credential
      debugPrint('[5/6] Creating credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase sign-in
      debugPrint('[6/6] Firebase sign-in...');
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint('');
      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ SUCCESS: ${userCredential.user?.email}');
      debugPrint('═══════════════════════════════════════');
      
      return userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Account exists with different method');
        case 'invalid-credential':
          throw Exception('Invalid credentials');
        default:
          throw Exception('Auth failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('💥 Error: $e');
      if (e.toString().toLowerCase().contains('cancel')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
}