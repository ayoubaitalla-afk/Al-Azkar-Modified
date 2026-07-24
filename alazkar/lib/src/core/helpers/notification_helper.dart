import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart' as material;
import 'package:alazkar/src/core/helpers/bookmarks_helper.dart';
import 'package:alazkar/src/core/helpers/azkar_helper.dart';
import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'package:alazkar/src/features/settings/data/repository/settings_storage.dart';
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

  /// إعادة جدولة جميع الإشعارات (العامة والمخصصة)
  Future<void> rescheduleDailyFavoriteAzkar() async {
    // إلغاء الكل أولاً لتجنب التكرار أو بقاء إشعارات محذوفة
    await cancelAllNotifications();

    final bookmarksHelper = sl<BookmarksDBHelper>();
    final azkarHelper = sl<AzkarDBHelper>();
    final settingsStorage = sl<SettingsStorage>();

    // 1. جدولة الإشعار اليومي العام (إذا كان مفعلاً)
    if (settingsStorage.dailyNotificationsEnabled) {
      final time = material.TimeOfDay(
        hour: settingsStorage.dailyNotificationsHour,
        minute: settingsStorage.dailyNotificationsMinute,
      );

      final favoriteIds = await bookmarksHelper.getAllFavoriteTitles();
      if (favoriteIds.isNotEmpty) {
        final randomId = favoriteIds[Random().nextInt(favoriteIds.length)];
        await _scheduleSingleZikr(0, randomId, time, "تذكير يومي بالأذكار");
      }
    }

    // 2. جدولة الإشعارات المخصصة لكل ذكر (أوقات متعددة)
    final favoritesWithTime = await bookmarksHelper.getAllFavoriteTitlesWithTime();
    for (var fav in favoritesWithTime) {
      final titleId = fav['titleId'] as int;
      final times = await bookmarksHelper.getNotificationTimes(titleId);
      
      for (int i = 0; i < times.length; i++) {
        final parts = times[i].split(':');
        final time = material.TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        
        // نستخدم titleId و index كـ ID للإشعار
        // نضيف 1000 + (index * 10000) لضمان عدم التعارض
        await _scheduleSingleZikr(titleId + 1000 + (i * 10000), titleId, time, "موعد ذكرك المفضل");
      }
    }

    // 3. جدولة الإشعارات التاريخية
    await _scheduleHistoricalNotifications();
  }

  Future<void> _scheduleHistoricalNotifications() async {
    final settingsStorage = sl<SettingsStorage>();
    final azkarHelper = sl<AzkarDBHelper>();
    final allTitles = await azkarHelper.getAllTitles();

    // أسبوعي
    if (settingsStorage.weeklyNotificationsEnabled) {
      final weeklyTitles = allTitles.where((t) => t.freq.contains('w')).toList();
      if (weeklyTitles.isNotEmpty) {
        final randomZikr = weeklyTitles[Random().nextInt(weeklyTitles.length)];
        await _schedulePeriodicZikr(200000, randomZikr.id, DateTimeComponents.dayOfWeekAndTime, "تذكير أسبوعي");
      }
    }

    // شهري
    if (settingsStorage.monthlyNotificationsEnabled) {
      final monthlyTitles = allTitles.where((t) => t.freq.contains('m')).toList();
      if (monthlyTitles.isNotEmpty) {
        final randomZikr = monthlyTitles[Random().nextInt(monthlyTitles.length)];
        await _schedulePeriodicZikr(300000, randomZikr.id, DateTimeComponents.dayOfMonthAndTime, "تذكير شهري");
      }
    }

    // سنوي
    if (settingsStorage.yearlyNotificationsEnabled) {
      final yearlyTitles = allTitles.where((t) => t.freq.contains('y')).toList();
      if (yearlyTitles.isNotEmpty) {
        final randomZikr = yearlyTitles[Random().nextInt(yearlyTitles.length)];
        await _schedulePeriodicZikr(400000, randomZikr.id, DateTimeComponents.dateAndTime, "تذكير سنوي");
      }
    }
  }

  Future<void> _schedulePeriodicZikr(int notificationId, int titleId, DateTimeComponents match, String channelName) async {
    final azkarHelper = sl<AzkarDBHelper>();
    final zikrTitle = await azkarHelper.getTitlesById(titleId);
    
    // وقت افتراضي للإشعارات الدورية (مثلاً 10 صباحاً)
    final time = material.TimeOfDay(hour: 10, minute: 0);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      zikrTitle.name,
      "لا تنسَ قراءة ${zikrTitle.name} (تذكير دوري)",
      _nextInstance(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'periodic_azkar_channel_$notificationId',
          channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: match,
    );
  }

  Future<void> _scheduleSingleZikr(int notificationId, int titleId, material.TimeOfDay time, String channelName) async {
    final azkarHelper = sl<AzkarDBHelper>();
    final zikrTitle = await azkarHelper.getTitlesById(titleId);
    final zikrContent = await azkarHelper.getContentByTitleId(titleId);
    
    String body = "حان وقت قراءة ${zikrTitle.name}";
    if (zikrContent.isNotEmpty) {
      final firstZikr = zikrContent.first;
      body = firstZikr.body ?? body;
      if (body.length > 100) {
        body = "${body.substring(0, 97)}...";
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      zikrTitle.name,
      body,
      _nextInstance(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_azkar_channel_$notificationId',
          channelName,
          channelDescription: 'تذكير مخصص بقراءة الأذكار',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
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
