import 'package:smart_parking_ble/app/routes/observer.dart';
import 'package:smart_parking_ble/app/wrapper/app_wrapper.dart';
import 'package:smart_parking_ble/features/auth/view/email_verify/view/verify_email_screen.dart';
import 'package:smart_parking_ble/features/auth/view/forget_password/forgot_password_screen.dart';
import 'package:smart_parking_ble/features/auth/view/forget_password/reset_password_screen.dart';
import 'package:smart_parking_ble/features/auth/view/login/login_screen.dart';
import 'package:smart_parking_ble/features/auth/view/login/login_using_email_screen.dart';
import 'package:smart_parking_ble/features/auth/view/signup/signup_email_screen.dart';
import 'package:smart_parking_ble/features/home/admin/navigation/view/admin_navigation.dart';
import 'package:smart_parking_ble/features/home/client/navigation/view/client_navigation.dart';
import 'package:smart_parking_ble/features/home/engineer/navigation/view/engineer_navigation.dart';
import 'package:smart_parking_ble/features/profile/view/account/account_screen.dart';
import 'package:smart_parking_ble/features/profile/view/profile/profile_setup_screen.dart';
import 'package:smart_parking_ble/features/settings/view/settings_screen.dart';
import 'package:smart_parking_ble/features/splash/view/spalsh_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final GlobalKey<NavigatorState> rootKey = ref.watch(
    _rootNavigatorKeyProvider,
  );

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    observers: [AnalyticsRouteObserver()],
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppWrapper(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/login-email',
            name: 'login-email',
            builder: (context, state) => const LoginWithEmailScreen(),
          ),
          GoRoute(
            path: '/sign-up',
            name: 'sign-up',
            builder: (context, state) => const SignupWithEmailScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/reset-password',
            name: 'reset-password',
            builder: (context, state) => const ResetPasswordScreen(),
          ),
          GoRoute(
            path: '/verify-email',
            name: 'verify-email',
            builder: (context, state) => const VerifyAccountScreen(),
          ),
          GoRoute(
            path: '/profile-setup',
            name: 'profile-setup',
            builder: (context, state) => const ProfileSetupScreen(),
          ),
          GoRoute(
            path: '/admin-home',
            name: 'admin-home',
            builder: (context, state) => const AdminNavigation(),
          ),
          GoRoute(
            path: '/client-home',
            name: 'client-home',
            builder: (context, state) => const ClientNavigation(),
          ),
          GoRoute(
            path: '/engineer-home',
            name: 'engineer-home',
            builder: (context, state) => const EngineerNavigation(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
    ],
  );
});
