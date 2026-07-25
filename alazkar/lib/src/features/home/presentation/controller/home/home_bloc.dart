@@
-import 'package:alazkar/src/core/helpers/azkar_helper.dart';
+import 'package:alazkar/src/core/helpers/azkar_helper.dart';
+import 'package:alazkar/src/core/time_period.dart';
@@
   Future<void> _start(
     HomeStartEvent event,
     Emitter<HomeState> emit,
   ) async {
     emit(HomeLoadingState());
 
     final List<ZikrTitle> titlesToSet;
 
     /// Get titles form db
     final List<ZikrTitle> dbTitles = (await azkarDBHelper.getAllTitles())
       ..sort(
         (a, b) => a.order.compareTo(b.order),
       );
@@
-    /// Filters
-    titlesToSet = await applyFiltersOnTitels(dbTitles, freq);
+    /// Determine current period and apply filters
+    final currentPeriod = dayPeriodToString(getCurrentDayPeriod());
+    titlesToSet = await applyFiltersOnTitels(dbTitles, freq, period: currentPeriod);
@@
-  Future<List<ZikrTitle>> applyFiltersOnTitels(
-    List<ZikrTitle> titles,
-    List<TitlesFreqEnum> titleFreqList, {
-    List<Filter>? zikrFilters,
-  }) async {
+  Future<List<ZikrTitle>> applyFiltersOnTitels(
+    List<ZikrTitle> titles,
+    List<TitlesFreqEnum> titleFreqList, {
+    List<Filter>? zikrFilters,
+    String? period,
+  }) async {
     final List<ZikrTitle> titlesToSet;
@@
-    final List<ZikrTitle> reducedTitles = List.of([]);
+    final List<ZikrTitle> reducedTitles = List.of([]);
     final List<Filter> filters =
         zikrFilters ?? zikrFilterStorage.getAllFilters();
     for (var i = 0; i < filterdFreqTitles.length; i++) {
       final title = filterdFreqTitles[i];
-      final azkarFromDB = await azkarDBHelper.getContentByTitleId(title.id);
+      // If period not provided, determine current period
+      period ??= dayPeriodToString(getCurrentDayPeriod());
+      // Get content filtered by period or 'all'
+      final azkarFromDB = await azkarDBHelper.getContentByTitleIdWithPeriod(title.id, period: period);
       final azkarToSet = filters.getFilteredZikr(azkarFromDB);
       if (azkarToSet.isNotEmpty) reducedTitles.add(title);
     }
*** End Patch
