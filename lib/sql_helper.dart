import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      domain TEXT,
      location TEXT,
      phoneNumber TEXT ,
      email TEXT ,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'ems_database.db'),
      onCreate: (db, version) async {
        await createTables(db);
      },
      version: 1,
    );
  }

  // Create new item
  static Future<int> createItem(String title, String domain, String location, String phoneNumber, String email) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'domain': domain, 'location': location, 'phoneNumber': phoneNumber, 'email': email};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  // Update an item by id
  static Future<int> updateItem(int id, String title, String domain, String location, String phoneNumber, String email) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'domain': domain,
      'location': location,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete an item by id
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}
