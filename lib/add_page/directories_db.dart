import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DirectoryDBHelpler {
  static Database? _database;

  static Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'directories.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE directories(path TEXT PRIMARY KEY)",
        );
      },
      version: 1,
    );
  }

  static Future<Database> getDBConnect() async =>
      _database ?? await initDatabase();

  static Future<void> insert(Directory dir) async {
    final Database db = await getDBConnect();

    await db.insert(
      'directories',
      {"path": dir.path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Directory>> paths() async {
    final Database db = await getDBConnect();

    final List<Map<String, dynamic>> maps = await db.query('directories');

    return List.generate(maps.length, (i) {
      return Directory(maps[i]["path"]);
    });
  }

  static Future<void> update(Directory dir) async {
    final Database db = await getDBConnect();

    await db.update(
      'directories',
      {"path": dir.path},
      where: "path = ?",
      whereArgs: [dir.path],
    );
  }

  static Future<void> delete(Directory dir) async {
    final Database db = await getDBConnect();

    await db.delete(
      'directories',
      where: "path = ?",
      whereArgs: [dir.path],
    );
  }
}
