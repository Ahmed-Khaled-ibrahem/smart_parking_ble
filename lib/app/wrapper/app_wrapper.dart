import 'package:smart_parking_ble/app/helpers/errors/error_mapper.dart';
import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:smart_parking_ble/app/helpers/toast/app_toast.dart';
import 'package:smart_parking_ble/app/routes/app_router.dart';
import 'package:smart_parking_ble/features/auth/controller/auth_controller.dart';
import 'package:smart_parking_ble/features/auth/model/app_user.dart';
import 'package:smart_parking_ble/features/profile/controller/profile_controller.dart';
import 'package:smart_parking_ble/features/profile/data_sources/profile_cache_service.dart';
import 'package:smart_parking_ble/features/profile/model/user_profile.dart';
import 'package:smart_parking_ble/features/splash/view/spalsh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key, required this.child});

  final Widget child;

  @override
  AppWrapperState createState() => AppWrapperState();
}

class AppWrapperState extends ConsumerState<AppWrapper> {
  bool loading = true;

  void handlingAuthNavigation(AppUser? user) async {
    try {
      final router = ref.read(appRouterProvider);

      if (user == null) {
        router.go('/login');
        return;
      }

      if (!(user.emailVerified)) {
        router.go('/verify-email');
        return;
      }

      final profileCtr = ref.read(profileControllerProvider.notifier);
      final profile = await profileCtr.readSyncProfile(user.uid);

      if (profile != null && profile.name != null) {

        switch (profile.role) {
          case UserRole.admin:
            router.go('/admin-home');
            break;
          case UserRole.engineer:
            router.go('/engineer-home');
            break;
          case UserRole.client:
            router.go('/client-home');
            break;
        }
      } else {
        router.go('/profile-setup');
      }
    } catch (e, s) {
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future initialize() async {
    // Hive
    await ref.read(profileCacheServiceProvider).init();

    setState(() {
      loading = false;
    });
    logApp('App Starts Here');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SplashScreen();
    }

    ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (previous, next) {
      if (next.isLoading) return;
      if (next.hasError) return;
      if (next.value?.isSameUser(previous?.value) ?? false) return;
      handlingAuthNavigation(next.value);
    });

    return widget.child;
  }
}
