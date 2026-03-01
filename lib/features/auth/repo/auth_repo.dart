import 'package:smart_parking_ble/app/const/hive_box_names.dart';
import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:smart_parking_ble/features/auth/service/auth_service.dart';
import 'package:smart_parking_ble/features/biometric/controller/biometric_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepoProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  final biometricService = ref.watch(biometricControllerProvider.notifier);

  return AuthRepository(
    authService,
    biometricService,
  );
});

class AuthRepository {
  final AuthService _authService;
  final BiometricController _biometricService;

  AuthRepository(
    this._authService,
    this._biometricService,
  );

  User? get currentUser => _authService.currentUser;

  Stream<User?> get userChanges => _authService.userChanges;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future appOpened() async {
    await biometricCheck();
    await reloadUser();
  }

  Future afterLogIn(User user) async {

  }

  Future afterLogOut() async {
    await _biometricService.setBiometricEnabled(false);
  }

  Future<void> listenToUserStatusChange(
    Future<void> Function(User?) callBack,
  ) async {
    authStateChanges.listen((User? user) async {
      if (user == null) {
        await afterLogOut();
      } else {
        await afterLogIn(user);
      }
      await callBack(user);
    });
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final User? user = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    if (user != null) {

    }
    return user;
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final User? user = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );
    if (user != null) {
      await sendEmailVerification(user);
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final User? user = await _authService.signInWithGoogle();
    if (user != null) {
    }
    return user;
  }

  Future<void> sendEmailVerification(User user) async {
    return await _authService.sendEmailVerification(user);
  }

  Future<void> reSendEmailVerification() async {
    if (currentUser == null) return;
    return await _authService.sendEmailVerification(currentUser!);
  }

  Future<User?> signOut() async {
    await _authService.signOut();
    return currentUser;
  }

  Future<void> deleteAccount() async {
    return await _authService.deleteAccount();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  Future biometricCheck() async {
    if (await _biometricService.getBiometricEnabled()) {
      bool success = false;
      while (!success) {
        success = await _biometricService.authenticate();
      }
    }
  }

  Future reloadUser() async {
    try {
      await _authService.reloadCurrentUser();
    } catch (e) {
      logApp('error reloading user : $e');
    }
  }
}
