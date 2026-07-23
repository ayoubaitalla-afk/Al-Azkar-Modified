import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart' as material;
import 'package:alazkar/src/core/helpers/bookmarks_helper.dart';
import 'package:alazkar/src/core/helpers/azkar_helper.dart';
import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'dart:math';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> scheduleDailyFavoriteAzkar({
    required material.TimeOfDay time,
  }) async {
    final bookmarksHelper = sl<BookmarksDBHelper>();
    final azkarHelper = sl<AzkarDBHelper>();
    
    final favoriteIds = await bookmarksHelper.getAllFavoriteTitles();
    if (favoriteIds.isEmpty) return;

    // اختيار ذكر عشوائي من المفضلات للإشعار
    final randomId = favoriteIds[Random().nextInt(favoriteIds.length)];
    final zikrTitle = await azkarHelper.getTitlesById(randomId);
    final zikrContent = await azkarHelper.getContentByTitleId(randomId);
    
    String body = "حان وقت قراءة ${zikrTitle.name}";
    if (zikrContent.isNotEmpty) {
      // محاولة أخذ جزء من النص كمعاينة
      final firstZikr = zikrContent.first;
      body = firstZikr.body ?? body;
      if (body.length > 100) {
        body = "${body.substring(0, 97)}...";
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID ثابت لإشعار اليوم الواحد لتجنب التكرار
      "تذكير بالأذكار",
      body,
      _nextInstance(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_azkar_channel',
          'إشعارات الأذكار اليومية',
          channelDescription: 'تذكير يومي بقراءة الأذكار المفضلة',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstance(material.TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
