import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _initDB('learning.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE Subject (
        subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Document (
        document_id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        summary_context TEXT NOT NULL,
        created_at TEXT NOT NULL,
        subject_id INTEGER NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES Subject (subject_id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE Flashcard (
        card_id INTEGER PRIMARY KEY AUTOINCREMENT,
        front_text TEXT NOT NULL,
        back_text TEXT NOT NULL,
        memory_level INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        document_id INTEGER NOT NULL,
        FOREIGN KEY (document_id) REFERENCES Document (document_id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE Quiz (
        question_id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_content TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        created_at TEXT NOT NULL,
        document_id INTEGER NOT NULL,
        FOREIGN KEY (document_id) REFERENCES Document (document_id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE Result (
        result_id INTEGER PRIMARY KEY AUTOINCREMENT,
        correct_answers INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        score REAL NOT NULL,
        attempt_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        document_id INTEGER NOT NULL,
        FOREIGN KEY (document_id) REFERENCES Document (document_id) ON DELETE CASCADE
      )
    ''');
  }
}
