import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/app/app.dart';
import 'package:smart_parking_ble/app/config/firebase_config.dart';
import 'package:smart_parking_ble/app/config/notifications_config.dart';
import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:smart_parking_ble/app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_parking_ble/screens/deactivate/deactivate_app.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      DateTime now = DateTime.now();
      DateTime date = DateTime(2026, 4, 1);

      if (now.isAfter(date)) {
        runApp(const DeactivateAppScreen());
        return;
      }
      // Initialize Hive
      await notificationsConfig();
      // Initialize Firebase
      await firebaseConfig();
      // Initialize Easy Localization
      await EasyLocalization.ensureInitialized();
      // setting orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      // Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        logApp('^^^ Uncaught error: $details');
        FlutterError.dumpErrorToConsole(details);
      };
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const AppErrorWidget();
      };
      runApp(const ProviderScope(child: App()));
    },
    (error, stack) {
      logApp('@@@ Uncaught async error: $error');
      logApp(stack.toString());
    },
  );
}
