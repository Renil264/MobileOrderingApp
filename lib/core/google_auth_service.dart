import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    debugPrint('🔧 Initializing GoogleAuthService...');
    
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      // Force standard sign-in (no silent sign-in on iOS)
      signInOption: SignInOption.standard,
    );
    
    debugPrint('✅ GoogleAuthService initialized');
  }

  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🚀 [1/6] Starting Google Sign-In...');
      
      // Check Firebase initialization
      try {
        final app = _auth.app;
        debugPrint('✅ [2/6] Firebase is initialized (${app.name})');
      } catch (e) {
        debugPrint('❌ Firebase not initialized: $e');
        throw Exception('Firebase initialization error');
      }

      // Sign out first to ensure clean state
      debugPrint('🔄 [3/6] Clearing previous session...');
      await _googleSignIn.signOut();
      
      // Trigger Google Sign-In
      debugPrint('📱 [4/6] Opening Google Sign-In dialog...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ User cancelled sign-in');
        return null;
      }

      debugPrint('✅ [5/6] Google account selected: ${googleUser.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('❌ Missing authentication tokens');
        throw Exception('Failed to obtain authentication tokens');
      }

      debugPrint('✅ Tokens obtained');

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      debugPrint('🔥 [6/6] Signing in to Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      debugPrint('✅ ✅ ✅ Sign-in successful! User: ${userCredential.user?.email}');
      return userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Account exists with different credentials');
        case 'invalid-credential':
          throw Exception('Invalid credentials');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In not enabled');
        case 'user-disabled':
          throw Exception('Account has been disabled');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('Stack: $stackTrace');
      
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('cancel')) {
        return null;
      } else if (errorStr.contains('network')) {
        throw Exception('Network error - check connection');
      } else if (errorStr.contains('sign_in_failed')) {
        throw Exception('Sign-in failed - please try again');
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
      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
}