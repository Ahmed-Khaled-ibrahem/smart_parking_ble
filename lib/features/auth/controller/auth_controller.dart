import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/helpers/toast/app_toast.dart';
import '../../../app/helpers/errors/error_mapper.dart';
import '../../../app/helpers/info/logging.dart';
import '../model/app_user.dart';
import '../repo/auth_repo.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  late AuthRepository authRepo;

  @override
  Future<AppUser?> build() async {
    authRepo = ref.watch(authRepoProvider);
    await authRepo.appOpened();
    await authRepo.listenToUserStatusChange(callBack);
    return authRepo.currentUser?.toAppUser();
  }

  Future<void> callBack(User? user) async {
    logApp('refreshing user state');
    state = AsyncData(user?.toAppUser());
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      logApp('click : sign up with email');
      final User? user = await authRepo.signUpWithEmail(
        email: email,
        password: password,
      );
      state = AsyncData(user?.toAppUser());
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      logApp('click : sign in with email');
      final User? user = await authRepo.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncData(user?.toAppUser());
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final User? user = await authRepo.signInWithGoogle();
      state = AsyncData(user?.toAppUser());
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authRepo.sendPasswordResetEmail(email);
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final User? user = await authRepo.signOut();
      state = AsyncData(user?.toAppUser());
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> deleteAccount() async {
    try {
      await authRepo.deleteAccount();
    } catch (e, s) {
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await authRepo.reSendEmailVerification();
    } catch (e, s) {
      state = AsyncError(e.toString(), StackTrace.current);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

}
