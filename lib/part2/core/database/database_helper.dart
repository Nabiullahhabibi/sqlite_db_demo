import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance =
      DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      DatabaseConstants.databaseName,
    );

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute(
      'PRAGMA foreign_keys = ON',
    );
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    if (version == 1) {
      await _createV1Schema(db);
      return;
    }

    await _createCurrentSchema(db);
  }

  // ------------------------------------------------------------
  // CURRENT DATABASE
  // ------------------------------------------------------------

  Future<void> _createCurrentSchema(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        age INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',

        FOREIGN KEY (user_id)
          REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');

    await _createIndexes(db);
  }

  // ------------------------------------------------------------
  // VERSION 1
  // ------------------------------------------------------------

  Future<void> _createV1Schema(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        age INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,

        FOREIGN KEY (user_id)
          REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');
  }

  // ------------------------------------------------------------
  // MIGRATIONS
  // ------------------------------------------------------------

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _upgradeToV2(db);
    }

    if (oldVersion < 3) {
      await _upgradeToV3(db);
    }
  }

  Future<void> _upgradeToV2(
    Database db,
  ) async {
    await db.execute('''
      ALTER TABLE users
      ADD COLUMN updated_at TEXT
    ''');

    await db.execute('''
      UPDATE users
      SET updated_at = created_at
    ''');

    await db.execute('''
      ALTER TABLE posts
      ADD COLUMN updated_at TEXT
    ''');

    await db.execute('''
      UPDATE posts
      SET updated_at = created_at
    ''');
  }

  Future<void> _upgradeToV3(
    Database db,
  ) async {
    await db.execute('''
      ALTER TABLE users
      ADD COLUMN sync_status TEXT NOT NULL
      DEFAULT 'synced'
    ''');

    await db.execute('''
      ALTER TABLE posts
      ADD COLUMN sync_status TEXT NOT NULL
      DEFAULT 'synced'
    ''');

    await _createIndexes(db);
  }

  // ------------------------------------------------------------
  // INDEXES
  // ------------------------------------------------------------

  Future<void> _createIndexes(
    Database db,
  ) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_posts_user_id
      ON posts(user_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_posts_created_at
      ON posts(created_at)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_posts_sync_status
      ON posts(sync_status)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_users_sync_status
      ON users(sync_status)
    ''');
  }
}