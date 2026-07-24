import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart' as material;
import 'package:alazkar/src/core/helpers/bookmarks_helper.dart';
import 'package:alazkar/src/core/helpers/azkar_helper.dart';
import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'package:alazkar/src/features/settings/data/repository/settings_storage.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

    // طلب أذونات الإشعارات والمنبهات الدقيقة (خاصة لأندرويد 13+ وشاومي)
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // 1. طلب إذن الإشعارات (أندرويد 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // 2. التحقق من إذن المنبهات الدقيقة (أندرويد 12+)
      // هذا ضروري لضمان عمل الأذكار في وقتها تماماً
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
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

  }

  // دالة لفتح إعدادات تحسين البطارية لشاومي
  Future<void> openBatteryOptimizationSettings() async {
    if (Platform.isAndroid) {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  Future<void> _scheduleSingleZikr(int notificationId, int titleId, material.TimeOfDay time, String channelName) async {
    final azkarHelper = sl<AzkarDBHelper>();
    final zikrTitle = await azkarHelper.getTitlesById(titleId);
    final zikrContent = await azkarHelper.getContentByTitleId(titleId);
    
    String body = "حان وقت قراءة ${zikrTitle.name}";
    if (zikrContent.isNotEmpty) {
      final firstZikr = zikrContent.first;
      body = firstZikr.body ?? body;
      // HyperOS may silently drop notifications with very long bodies.
      // Truncate aggressively to 60 characters to be absolutely safe.
      if (body.length > 60) {
        body = "${body.substring(0, 57)}...";
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      zikrTitle.name,
      body,
      _nextInstance(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_v3_daily_$notificationId',
          channelName,
          channelDescription: 'تذكير مخصص بقراءة الأذكار',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          showWhen: true,
          ongoing: false,
          autoCancel: true,
          ticker: 'تذكير بذكر الله',
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: const material.Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Using exactAllowWhileIdle is crucial for HyperOS to wake up the device
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
