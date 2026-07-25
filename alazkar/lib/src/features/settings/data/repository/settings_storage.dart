@@
   static const String _dailyNotificationsMinuteKey = "dailyNotificationsMinute";
@@
   Future setDailyNotificationsEnabled(bool value) => _box.write(_dailyNotificationsEnabledKey, value);
   Future setDailyNotificationsTime(int hour, int minute) async {
     await _box.write(_dailyNotificationsHourKey, hour);
     await _box.write(_dailyNotificationsMinuteKey, minute);
   }
+
+  /// Period notifications (morning/evening)
+  static const String _periodNotificationsEnabledKey = "periodNotificationsEnabled";
+  static const String _morningHourKey = "morningHour";
+  static const String _morningMinuteKey = "morningMinute";
+  static const String _eveningHourKey = "eveningHour";
+  static const String _eveningMinuteKey = "eveningMinute";
+
+  bool get periodNotificationsEnabled => _box.read(_periodNotificationsEnabledKey) ?? false;
+  int get morningHour => _box.read(_morningHourKey) ?? 6;
+  int get morningMinute => _box.read(_morningMinuteKey) ?? 0;
+  int get eveningHour => _box.read(_eveningHourKey) ?? 18;
+  int get eveningMinute => _box.read(_eveningMinuteKey) ?? 0;
+
+  Future setPeriodNotificationsEnabled(bool value) => _box.write(_periodNotificationsEnabledKey, value);
+  Future setMorningNotificationTime(int hour, int minute) async {
+    await _box.write(_morningHourKey, hour);
+    await _box.write(_morningMinuteKey, minute);
+  }
+  Future setEveningNotificationTime(int hour, int minute) async {
+    await _box.write(_eveningHourKey, hour);
+    await _box.write(_eveningMinuteKey, minute);
+  }
*** End Patch
