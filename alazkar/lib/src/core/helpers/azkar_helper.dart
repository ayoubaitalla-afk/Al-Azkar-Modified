@@
   Future<List<Zikr>> getContentByTitleId(int id) async {
     final Database db = await database;
-
-    final List<Map<String, dynamic>> maps = await db.rawQuery(
-      'SELECT * FROM contents WHERE titleId = ? ORDER BY `order` ASC',
-      [id],
-    );
-
-    return flattenZikrBodyText(
-      List.generate(maps.length, (i) {
-        return Zikr.fromMap(maps[i]);
-      }),
-    );
+    // Backwards compatible: if period is not provided, return all contents for the title
+    final List<Map<String, dynamic>> maps = await db.rawQuery(
+      'SELECT * FROM contents WHERE titleId = ? ORDER BY `order` ASC',
+      [id],
+    );
+
+    return flattenZikrBodyText(
+      List.generate(maps.length, (i) {
+        return Zikr.fromMap(maps[i]);
+      }),
+    );
   }
+
+  // New: get contents filtered by period (e.g., 'morning','evening','all')
+  Future<List<Zikr>> getContentByTitleIdWithPeriod(int id, {String? period}) async {
+    final Database db = await database;
+
+    if (period == null) {
+      return getContentByTitleId(id);
+    }
+
+    final List<Map<String, dynamic>> maps = await db.rawQuery(
+      'SELECT * FROM contents WHERE titleId = ? AND (period = ? OR period = ?) ORDER BY `order` ASC',
+      [id, period, 'all'],
+    );
+
+    return flattenZikrBodyText(
+      List.generate(maps.length, (i) {
+        return Zikr.fromMap(maps[i]);
+      }),
+    );
+  }
*** End Patch
