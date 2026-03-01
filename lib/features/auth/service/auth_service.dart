import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<User?> get userChanges => _auth.userChanges();

  // Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    return user;
  }

  Future<void> sendEmailVerification(User user) async {
    // Send email verification
    return await user.sendEmailVerification();
  }

  // Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    return user;
  }

  Future<void> _initializeGoogleSignIn() async {
      await _googleSignIn.initialize(
        clientId: Platform.isIOS
            ? '894406491508-eev3cll7teti26saqr57p2j5flcfgkda.apps.googleusercontent.com'
            : null,
      );
      _isGoogleSignInInitialized = true;
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<GoogleSignInAccount> signInWithGoogleAccount() async {
    await _ensureGoogleSignInInitialized();
    final GoogleSignInAccount account = await _googleSignIn.authenticate(
      scopeHint: ['email'],
    );
    return account;
  }

  Future<User?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    // Authenticate with Google
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
      scopeHint: ['email'],
    );
    // Get the authentication tokens from the GoogleSignInAccount
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final authClient = _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes([
      'email',
      'profile',
    ]);
    // Create a credential for Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: googleAuth.idToken,
    );
    // Sign in to Firebase with the credential
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    return userCredential.user;
  }

  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureGoogleSignInInitialized();
    final result = _googleSignIn.attemptLightweightAuthentication();
    if (result is Future<GoogleSignInAccount?>) {
      return await result;
    } else {
      return result as GoogleSignInAccount?;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<void> reloadCurrentUser() async {
    final user = currentUser;
    if (user == null) return;
    await user.reload();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
