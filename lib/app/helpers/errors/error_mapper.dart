import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ErrorMapper {
  ErrorMapper._();

  static final ErrorMapper instance = ErrorMapper._();

  factory ErrorMapper() => instance;

  // Firebase Auth error messages
  static const Map<String, String> _firebaseAuthErrors = {
    'email-already-in-use':
        'This email is already registered. Try logging in instead.',
    'invalid-email': 'Please enter a valid email address.',
    'operation-not-allowed':
        'This operation is not allowed. Please contact support.',
    'weak-password':
        'Password is too weak. Use at least 6 characters with letters and numbers.',
    'user-disabled': 'This account has been disabled. Please contact support.',
    'user-not-found': 'No account found with this email. Please sign up first.',
    'wrong-password': 'Incorrect password. Please try again.',
    'invalid-credential':
        'Invalid credentials. Please check your email and password.',
    'account-exists-with-different-credential':
        'An account already exists with this email using a different sign-in method.',
    'invalid-verification-code': 'Invalid verification code. Please try again.',
    'invalid-verification-id':
        'Verification session expired. Please request a new code.',
    'too-many-requests': 'Too many attempts. Please try again later.',
    'network-request-failed':
        'Network error. Please check your internet connection.',
    'requires-recent-login':
        'This operation requires recent authentication. Please log in again.',
    'expired-action-code': 'This link has expired. Please request a new one.',
    'invalid-action-code': 'This link is invalid or has already been used.',
  };

  // Firestore error messages
  static const Map<String, String> _firestoreErrors = {
    'permission-denied': 'You don\'t have permission to access this data.',
    'unavailable': 'Service temporarily unavailable. Please try again.',
    'not-found': 'The requested data was not found.',
    'already-exists': 'This data already exists.',
    'resource-exhausted': 'Too many requests. Please try again later.',
    'failed-precondition': 'Operation failed. Please try again.',
    'aborted': 'Operation was aborted. Please try again.',
    'out-of-range': 'Invalid data range provided.',
    'unimplemented': 'This feature is not yet available.',
    'internal': 'An internal error occurred. Please try again.',
    'data-loss': 'Data loss detected. Please contact support.',
    'unauthenticated': 'You need to be logged in to perform this action.',
    'deadline-exceeded':
        'Request timeout. Please check your connection and try again.',
    'cancelled': 'Operation was cancelled.',
  };

  // Platform-specific errors
  static const Map<String, String> _platformErrors = {
    'sign_in_failed': 'Sign in was cancelled or failed. Please try again.',
    'network_error': 'Network error. Please check your internet connection.',
    'sign_in_canceled': 'Sign in was cancelled.',
  };

  String getErrorMessage(Object error, StackTrace s) {
    String message = _mapError(error);
    logApp('## Error logged ## : ${error.toString()} ');
    logApp('## message logged ## : $message ');
    print(s);
    return message;
  }

  String _mapError(Object error) {
    // Handle FirebaseAuthException
    if (error is FirebaseAuthException) {
      return _firebaseAuthErrors[error.code] ??
          'Authentication error: ${error.message ?? "Unknown error"}';
    }

    // Handle FirebaseException (Firestore, Storage, etc.)
    if (error is FirebaseException) {
      return _firestoreErrors[error.code] ??
          'An error occurred: ${error.message ?? "Unknown error"}';
    }

    // Handle PlatformException (Google Sign In, etc.)
    if (error is PlatformException) {
      return _platformErrors[error.code] ??
          error.message ??
          'An unexpected error occurred. Please try again.';
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'No internet connection. Please check your network.';
    }

    // Handle timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Handle format exceptions
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again later.';
  }
}
