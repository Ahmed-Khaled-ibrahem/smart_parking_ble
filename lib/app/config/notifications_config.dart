import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print('🔵 Background notification tapped');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future notificationsConfig() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: settings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    onDidReceiveNotificationResponse: (e) {
      print('received');
    },
  );

  // timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  // create channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'parking_channel',
    'Parking Notifications',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

void scheduleNotificationSeconds(int seconds) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    title: 'Parking Reminder 🚗',
    body: 'Parking time is over!',
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'parking_channel',
        'Parking Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    ),
  );
}
