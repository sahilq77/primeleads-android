import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'leads.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lead_id TEXT,
            lead_name TEXT,
            reminder_date TEXT,
            reminder_time TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateReminder(
    String leadId,
    Map<String, dynamic> reminder,
  ) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder,
      where: 'lead_id = ?',
      whereArgs: [leadId],
    );
  }

  Future<Map<String, dynamic>?> getReminderByLeadId(String leadId) async {
    final db = await database;
    final result = await db.query(
      'reminders',
      where: 'lead_id = ?',
      whereArgs: [leadId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('reminders');
  }

  Future<void> deleteReminder(int id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
