import 'package:locked_notes_app/models/notes_model.dart';
import 'package:locked_notes_app/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._init();

  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('locked_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        userId     INTEGER NOT NULL,
        title      TEXT    NOT NULL,
        content    TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isLocked   INTEGER NOT NULL DEFAULT 0,
        createdAt  INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_notes_userId ON notes(userId)');
  }

  // ── User methods ────────────────────────────────────────────────────────────

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return rows.isNotEmpty ? UserModel.fromMap(rows.first) : null;
  }

  Future<UserModel?> getUser(int userId) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return rows.isNotEmpty ? UserModel.fromMap(rows.first) : null;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return rows.isNotEmpty;
  }

  // ── Notes methods ────────────────────────────────────────────────────────────

  Future<int> createNote(NotesModel note, int userId) async {
    final db = await database;
    final map = note.toMap()..['userId'] = userId;
    return db.insert('notes', map);
  }

  Future<List<NotesModel>> getNotes(int userId) async {
    final db = await database;
    final rows = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(NotesModel.fromMap).toList();
  }

  Future<List<NotesModel>> getLockedNotes(int userId) async {
    final db = await database;
    final rows = await db.query(
      'notes',
      where: 'userId = ? AND isLocked = 1',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(NotesModel.fromMap).toList();
  }

  Future<int> updateNote(NotesModel note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }
}
