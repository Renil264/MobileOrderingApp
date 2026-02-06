import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    debugPrint('🔧 Initializing Google Sign-In...');
    
    try {
      // Verify GoogleService-Info.plist exists
      if (Platform.isIOS) {
        debugPrint('📱 Platform: iOS');
        debugPrint('⚠️ Make sure GoogleService-Info.plist is in ios/Runner/');
        debugPrint('⚠️ Make sure it contains CLIENT_ID key');
      }
      
      _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      );
      
      debugPrint('✅ Google Sign-In initialized');
    } catch (e, stack) {
      debugPrint('❌ Google Sign-In initialization failed');
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');
      debugPrint('');
      debugPrint('🔴 CONFIGURATION ERROR:');
      debugPrint('1. Check GoogleService-Info.plist exists in ios/Runner/');
      debugPrint('2. Verify it contains CLIENT_ID key');
      debugPrint('3. Re-download from Firebase Console if needed');
    }
  }

  Future<User?> signInWithGoogle() async {
    if (_googleSignIn == null) {
      throw Exception(
        'Google Sign-In not initialized. Check GoogleService-Info.plist configuration.'
      );
    }

    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 GOOGLE SIGN-IN STARTING');
    debugPrint('═══════════════════════════════════════');

    try {
      // Verify Firebase
      debugPrint('[1/6] Verifying Firebase...');
      final app = _auth.app;
      debugPrint('✅ Firebase OK: ${app.name}');

      // Sign out previous session
      debugPrint('[2/6] Clearing session...');
      await _googleSignIn!.signOut();
      debugPrint('✅ Session cleared');

      // Launch sign-in
      debugPrint('[3/6] 🚀 Launching Google Sign-In UI...');
      debugPrint('(Crash would happen HERE if config is wrong)');
      
      GoogleSignInAccount? googleUser;
      
      try {
        googleUser = await _googleSignIn!.signIn().timeout(
          const Duration(seconds: 120),
        );
      } on PlatformException catch (e) {
        debugPrint('');
        debugPrint('❌ PlatformException caught!');
        debugPrint('Code: ${e.code}');
        debugPrint('Message: ${e.message}');
        debugPrint('Details: ${e.details}');
        
        if (e.code == 'sign_in_failed' && e.message?.contains('CLIENT_ID') == true) {
          throw Exception(
            'Google Sign-In configuration error. '
            'GoogleService-Info.plist is missing CLIENT_ID. '
            'Please re-download it from Firebase Console.'
          );
        }
        
        throw Exception('Google Sign-In failed: ${e.message}');
      } catch (e) {
        debugPrint('❌ Sign-in UI launch failed: $e');
        throw Exception('Failed to launch Google Sign-In: $e');
      }

      if (googleUser == null) {
        debugPrint('⚠️ User cancelled');
        return null;
      }

      debugPrint('✅ Account selected: ${googleUser.email}');

      // Get tokens
      debugPrint('[4/6] Getting tokens...');
      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get authentication tokens');
      }

      debugPrint('✅ Tokens received');

      // Create credential
      debugPrint('[5/6] Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      debugPrint('[6/6] Signing in to Firebase...');
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
          throw Exception('Account exists with different sign-in method');
        case 'invalid-credential':
          throw Exception('Invalid credentials');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In not enabled in Firebase Console');
        default:
          throw Exception('Auth error: ${e.message}');
      }
    } on TimeoutException {
      throw Exception('Sign-in timed out');
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
        if (_googleSignIn != null) _googleSignIn!.signOut(),
      ]);
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
}