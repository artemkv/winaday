import 'package:shared_preferences/shared_preferences.dart';

import 'package:winaday/domain.dart';

const String showNotificationsKey = "SHOW_NOTIFICATIONS";
const String notificationTimeHourKey = "NOTIFICATION_HOUR";
const String notificationTimeMinuteKey = "NOTIFICATION_MINUTE";

Future<AppSettings> getAppSettings() async {
  final prefs = await SharedPreferences.getInstance();

  final showNotification = prefs.getBool(showNotificationsKey) ?? false;
  final notificationTimeHour = prefs.getInt(notificationTimeHourKey) ?? 20;
  final notificationTimeMinute = prefs.getInt(notificationTimeMinuteKey) ?? 0;

  return AppSettings(
      showNotification, notificationTimeHour, notificationTimeMinute);
}

Future<void> saveAppSettings(AppSettings appSettings) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setBool(showNotificationsKey, appSettings.showNotifications);
  prefs.setInt(notificationTimeHourKey, appSettings.notificationTimeHour);
  prefs.setInt(notificationTimeMinuteKey, appSettings.notificationTimeMinute);
}
