import 'dart:async';
import 'dart:io';

import 'package:alazkar/src/core/utils/app_print.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BookmarksDBHelper {
  /* ************* Variables ************* */

  static const String dbName = "Bookmarks.db";
  static const int dbVersion = 4;

  /* ************* Singleton Constructor ************* */

  static BookmarksDBHelper? _databaseHelper;
  static Database? _database;

  factory BookmarksDBHelper() {
    _databaseHelper ??= BookmarksDBHelper._createInstance();
    return _databaseHelper!;
  }

  BookmarksDBHelper._createInstance();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    // Ensure the database is initialized
    await database;
  }

  /* ************* Database Creation ************* */

  // init
  Future<Database> _initDatabase() async {
    late final String path;
    if (Platform.isWindows) {
      final dbPath = (await getApplicationSupportDirectory()).path;
      path = join(dbPath, dbName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      onDowngrade: _onDowngradeDatabase,
    );
  }

  /// On create database
  Future<void> _onCreateDatabase(Database db, int version) async {
    appPrint("Create Bookmarks.db");

    /// Create favourite_contents table
    await db.execute('''
    CREATE TABLE "favourite_contents" (
      "id"	INTEGER NOT NULL UNIQUE,
      "contentId"	INTEGER NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');

    /// Create favourite_titles table
    await db.execute('''
    CREATE TABLE "favourite_titles" (
      "id"	INTEGER NOT NULL UNIQUE,
      "titleId"	INTEGER NOT NULL UNIQUE,
      "notification_times" TEXT, -- JSON array of times e.g. ["08:00", "14:00"]
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''');

    ///
    await addDefaultTitles(db);
  }

  /// default favourite titles
  Future addDefaultTitles(Database db) async {
    await db.execute('''
    INSERT OR IGNORE INTO favourite_titles(titleId) VALUES
    (2),     --  أذكار الاستيقاظ
    (84),    --  أذكار بعد السلام الصلاة
    (89),    --  الصباح
    (94),    --  المساء
    (99),    --  النوم
    (191),   --  السفر
    (254);   --  دخول السوق
    ''');
  }

  /// On upgrade database version
  Future<void> _onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await addDefaultTitles(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE favourite_titles ADD COLUMN notification_time TEXT',
      );
    }
    if (oldVersion < 4) {
      // Migrate notification_time to notification_times
      await db.execute(
        'ALTER TABLE favourite_titles ADD COLUMN notification_times TEXT',
      );
      final List<Map<String, dynamic>> favs = await db.query('favourite_titles');
      for (var fav in favs) {
        final time = fav['notification_time'] as String?;
        if (time != null && time.isNotEmpty) {
          await db.update(
            'favourite_titles',
            {'notification_times': '["$time"]'},
            where: 'id = ?',
            whereArgs: [fav['id']],
          );
        }
      }
    }
  }

  /// On downgrade database version
  Future<void> _onDowngradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  /* ************* Functions ************* */

  Future<List<Map<String, dynamic>>> getAllFavoriteTitlesWithTime() async {
    final Database db = await database;
    return await db.rawQuery(
      '''SELECT * from favourite_titles order by titleId asc''',
    );
  }

  Future<List<int>> getAllFavoriteTitles() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT titleId from favourite_titles order by titleId asc''',
    );

    return List.generate(maps.length, (i) {
      return maps[i]["titleId"] as int;
    });
  }

  Future<void> updateNotificationTimes({
    required int titleId,
    required List<String> times,
  }) async {
    final db = await database;
    final String timesJson = times.isEmpty ? "" : '["${times.join('","')}"]';
    await db.rawUpdate(
      'UPDATE favourite_titles SET notification_times = ? WHERE titleId = ?',
      [timesJson, titleId],
    );
  }

  Future<List<String>> getNotificationTimes(int titleId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'favourite_titles',
      columns: ['notification_times'],
      where: 'titleId = ?',
      whereArgs: [titleId],
    );
    if (result.isNotEmpty) {
      final String? timesJson = result.first['notification_times'] as String?;
      if (timesJson != null && timesJson.isNotEmpty) {
        // Simple manual parsing since it's a basic JSON array
        return timesJson
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  /// Add title to favourite
  Future<void> addTitleToFavourite({
    required int titleId,
  }) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR IGNORE INTO favourite_titles( titleId) VALUES(?)',
      [titleId],
    );
  }

  Future<void> deleteTitleFromFavourite({
    required int titleId,
  }) async {
    final db = await database;

    await db
        .rawDelete("DELETE FROM favourite_titles WHERE titleId = ?", [titleId]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
