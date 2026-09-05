import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      DatabaseConstants.databaseName,
    );

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.usersTable} (
        ${DatabaseConstants.columnId}
            INTEGER PRIMARY KEY AUTOINCREMENT,

        ${DatabaseConstants.columnName}
            TEXT NOT NULL,

        ${DatabaseConstants.columnEmail}
            TEXT NOT NULL,

        ${DatabaseConstants.columnAge}
            INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    // Future migrations go here.
    //
    // Example:
    //
    // if (oldVersion < 2) {
    //   await db.execute(
    //     'ALTER TABLE users ADD COLUMN phone TEXT',
    //   );
    // }
  }

  Future<void> closeDatabase() async {
    final db = await database;

    await db.close();

    _database = null;
  }

  Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      DatabaseConstants.databaseName,
    );

    await deleteDatabase(path);

    _database = null;
  }
}