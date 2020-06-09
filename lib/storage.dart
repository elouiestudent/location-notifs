/*
Name: Elizabeth Louie
Date: 6/8/2020
Purpose: file that stores all shared preferences calls
*/

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> setNotificationPreference(
      String notificationPreference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("notification-preference", notificationPreference);
  }

  static Future<String> getNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("notification-preference");
  }

  static Future<void> setNotificationFrequency(String id, int increment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(id))
      prefs.setInt(id, prefs.getInt(id) + increment);
    else {
      prefs.setInt(id, increment);
      
      var notifList;
      if (prefs.containsKey("notifications-list"))
        notifList = prefs.getStringList("notifications-list");
      else
        notifList = [];

      notifList.add(id);
      prefs.setStringList("notifications-list", notifList);
    }
  }

  static Future<int> getNotificationFrequency(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(id))
      return prefs.getInt(id);
    else
      return 0;
  }

  static Future<void> resetNotificationFrequencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("notifications-list")) {
      var notifList = prefs.getStringList("notifications-list");
      notifList.forEach((id) {
        prefs.remove(id);
      });
      prefs.remove("notifications-list");
    }
  }
}
