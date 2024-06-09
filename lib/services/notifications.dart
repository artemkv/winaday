import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../domain.dart';
import 'settings.dart';

class NotificationService {
  static const AndroidInitializationSettings settingsAndroid =
      AndroidInitializationSettings('ic_notification');

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  Future<void> init() async {
    InitializationSettings settings =
        const InitializationSettings(android: settingsAndroid);

    bool? initialized = await notificationsPlugin.initialize(settings);
    if (!(initialized ?? false)) {
      log('Could not initialize the notification plugin',
          level: Level.SEVERE.value);
      return;
    }

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  Future<void> setupNotifications() async {
    var appSettings = await getAppSettings();
    if (appSettings.showNotifications) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('reminder', 'User-configured reminder',
              channelDescription: 'Notifications configured by the user');
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await notificationsPlugin.zonedSchedule(
          0,
          'Have you got the win?',
          'All you need a one small win a day!',
          getScheduledTime(appSettings),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time);
    } else {
      await notificationsPlugin.cancel(0);
    }
  }

  tz.TZDateTime getScheduledTime(AppSettings appSettings) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        appSettings.notificationTimeHour,
        appSettings.notificationTimeMinute,
        0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
