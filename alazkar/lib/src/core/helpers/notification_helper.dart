@@
 import 'package:alazkar/src/core/helpers/notification_helper.dart';
 import 'package:alazkar/src/core/di/dependency_injection.dart';
 import 'package:alazkar/src/core/models/zikr_title.dart';
 import 'package:alazkar/src/core/utils/app_print.dart';
 import 'package:alazkar/src/features/home/data/models/titles_freq_enum.dart';
 import 'package:alazkar/src/features/zikr_source_filter/data/models/zikr_filter.dart';
@@
   Future<void> rescheduleDailyFavoriteAzkar() async {
     // إلغاء الكل أولاً لتجنب التكرار أو بقاء إشعارات محذوفة
     await cancelAllNotifications();
@@
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
+
+    // 3. جدولة إشعارات الفترات (صباح/مساء) إن كانت مفعلة في الإعدادات
+    try {
+      final settingsStorage = sl<SettingsStorage>();
+      if (settingsStorage.periodNotificationsEnabled) {
+        final morningTime = material.TimeOfDay(
+          hour: settingsStorage.morningHour,
+          minute: settingsStorage.morningMinute,
+        );
+        final eveningTime = material.TimeOfDay(
+          hour: settingsStorage.eveningHour,
+          minute: settingsStorage.eveningMinute,
+        );
+
+        await _schedulePeriodNotification('morning', morningTime, 'أذكار الصباح');
+        await _schedulePeriodNotification('evening', eveningTime, 'أذكار المساء');
+      }
+    } catch (e) {
+      appPrint('Failed to schedule period notifications: $e');
+    }
@@
   }
+
+  Future<void> _schedulePeriodNotification(String period, material.TimeOfDay time, String channelName) async {
+    final azkarHelper = sl<AzkarDBHelper>();
+    final random = Random();
+
+    // جمع عناوين التي تحتوي على محتوى للفترة المحددة
+    final allTitles = await azkarHelper.getAllTitles();
+    final List<int> candidateIds = [];
+    for (final t in allTitles) {
+      final contents = await azkarHelper.getContentByTitleIdWithPeriod(t.id, period: period);
+      if (contents.isNotEmpty) candidateIds.add(t.id);
+    }
+
+    if (candidateIds.isEmpty) return;
+
+    final chosen = candidateIds[random.nextInt(candidateIds.length)];
+    // استخدم معرف مميز لكل فترة لتجنب التعارضات
+    final notificationId = period == 'morning' ? 2001 : 2002;
+    await _scheduleSingleZikr(notificationId, chosen, time, channelName);
+  }
*** End Patch
