import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';

class WishlistDatabaseHelper implements DatabaseHelperCommon {
  @override
  Future<int> createItem(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.db();
    final id = await db.insert("wishlist", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Similar for updateItem
  @override
  Future<int> updateItem(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.db();
    final result = await db.update("wishlist", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query("wishlist", orderBy: "id");
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query("wishlist", where: "id = ?", whereArgs: [id], limit: 1);
  }

  @override
  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("wishlist", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}