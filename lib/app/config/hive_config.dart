import 'package:hive_flutter/hive_flutter.dart';

Future hiveConfig() async {
  await Hive.initFlutter();
  // Hive.registerAdapter(UserRoleAdapter());
}
