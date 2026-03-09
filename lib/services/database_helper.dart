import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _webBoxName = 'web_notes';

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Return a factory-based mock or similar if needed. 
      // For now, we'll just handle it in the getter or return a dummy.
      throw UnsupportedError('SQLite is not supported on web in this demo.');
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0'; // 0 for false, 1 for true

    await db.execute('''
    CREATE TABLE notes (
      id $idType,
      title $textType,
      content $textType,
      created_at $textType,
      is_completed $boolType
    )
    ''');
  }

  Future<int> createNote(Map<String, dynamic> note) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBoxName);
      final id = DateTime.now().millisecondsSinceEpoch;
      final noteWithId = Map<String, dynamic>.from(note);
      noteWithId['id'] = id;
      noteWithId['is_completed'] = 0; // the default value is false
      await box.put(id, noteWithId);
      return id;
    }
    try {
      final db = await instance.database;
      if (db == null) return 0; // this should not happen if kIsWeb is false, but for safety
      return await db.insert('notes', note);
    } catch (e) {
      // might log error incase
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBoxName);
      final notes = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
      notes.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      return notes;
    }
    try {
      final db = await instance.database;
      if (db == null) return []; // this should not happen if kIsWeb is false, but for safety
      return await db.query('notes', orderBy: 'created_at DESC');
    } catch (e) {
      // might log error incase
      return [];
    }
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBoxName);
      final existing = box.get(id);
      if (existing != null) {
        final updated = Map<String, dynamic>.from(existing);
        updated.addAll(note);
        await box.put(id, updated);
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBoxName);
      await box.delete(id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db?.close();
  }
}