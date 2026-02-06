import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // Add iOS-specific client ID if you have one
    // serverClientId: 'YOUR_IOS_CLIENT_ID', // Optional
  );

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if we got the tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('Failed to get Google auth tokens');
        throw Exception('Failed to get authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      debugPrint('Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with the same email but different sign-in credentials');
        case 'invalid-credential':
          throw Exception('Invalid credentials. Please try again');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled. Please contact support');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'user-not-found':
          throw Exception('No user found with this credential');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      
      // Handle specific Google Sign-In errors
      if (e.toString().contains('SIGN_IN_CANCELLED')) {
        return null; // User cancelled
      } else if (e.toString().contains('SIGN_IN_FAILED')) {
        throw Exception('Sign-in failed. Please check your internet connection');
      } else if (e.toString().contains('NETWORK_ERROR')) {
        throw Exception('Network error. Please check your connection');
      }
      
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('Sign out successful');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}