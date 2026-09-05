import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MigrationTestResult {
  final bool success;
  final List<String> messages;

  const MigrationTestResult({
    required this.success,
    required this.messages,
  });
}

class DatabaseMigrationTest {
  DatabaseMigrationTest._();

  static Future<MigrationTestResult> run() async {
    final messages = <String>[];

    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'migration_test.db',
    );

    try {
      // Remove previous test database.
      await deleteDatabase(path);

      // --------------------------------------------------------
      // STEP 1 — Create V1
      // --------------------------------------------------------

      final dbV1 = await openDatabase(
        path,
        version: 1,
        onConfigure: (db) async {
          await db.execute(
            'PRAGMA foreign_keys = ON',
          );
        },
        onCreate: (db, version) async {
          await _createV1Schema(db);
        },
      );

      messages.add(
        '✓ Created database version 1',
      );

      // Insert test user.
      final userId = await dbV1.insert(
        'users',
        {
          'name': 'Migration Test User',
          'email': 'migration@test.com',
          'age': 25,
          'created_at':
              DateTime.now().toIso8601String(),
        },
      );

      // Insert test post.
      await dbV1.insert(
        'posts',
        {
          'user_id': userId,
          'title': 'Migration Test Post',
          'body': 'This data should survive migration.',
          'created_at':
              DateTime.now().toIso8601String(),
        },
      );

      messages.add(
        '✓ Inserted V1 test data',
      );

      await dbV1.close();

      // --------------------------------------------------------
      // STEP 2 — V1 → V2
      // --------------------------------------------------------

      final dbV2 = await openDatabase(
        path,
        version: 2,
        onConfigure: (db) async {
          await db.execute(
            'PRAGMA foreign_keys = ON',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
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
        },
      );

      final userColumnsV2 =
          await dbV2.rawQuery(
        'PRAGMA table_info(users)',
      );

      final postColumnsV2 =
          await dbV2.rawQuery(
        'PRAGMA table_info(posts)',
      );

      final hasUserUpdatedAt =
          _hasColumn(
        userColumnsV2,
        'updated_at',
      );

      final hasPostUpdatedAt =
          _hasColumn(
        postColumnsV2,
        'updated_at',
      );

      if (!hasUserUpdatedAt ||
          !hasPostUpdatedAt) {
        throw Exception(
          'V2 migration failed: updated_at missing',
        );
      }

      messages.add(
        '✓ Migrated V1 → V2',
      );

      messages.add(
        '✓ updated_at columns exist',
      );

      await dbV2.close();

      // --------------------------------------------------------
      // STEP 3 — V2 → V3
      // --------------------------------------------------------

      final dbV3 = await openDatabase(
        path,
        version: 3,
        onConfigure: (db) async {
          await db.execute(
            'PRAGMA foreign_keys = ON',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
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
        },
      );

      messages.add(
        '✓ Migrated V2 → V3',
      );

      // --------------------------------------------------------
      // STEP 4 — Verify V3 columns
      // --------------------------------------------------------

      final userColumnsV3 =
          await dbV3.rawQuery(
        'PRAGMA table_info(users)',
      );

      final postColumnsV3 =
          await dbV3.rawQuery(
        'PRAGMA table_info(posts)',
      );

      if (!_hasColumn(
            userColumnsV3,
            'sync_status',
          ) ||
          !_hasColumn(
            postColumnsV3,
            'sync_status',
          )) {
        throw Exception(
          'V3 migration failed: sync_status missing',
        );
      }

      messages.add(
        '✓ sync_status columns exist',
      );

      // --------------------------------------------------------
      // STEP 5 — Verify data survived
      // --------------------------------------------------------

      final users = await dbV3.query(
        'users',
      );

      final posts = await dbV3.query(
        'posts',
      );

      if (users.length != 1) {
        throw Exception(
          'User data was not preserved',
        );
      }

      if (posts.length != 1) {
        throw Exception(
          'Post data was not preserved',
        );
      }

      messages.add(
        '✓ Original data preserved',
      );

      // --------------------------------------------------------
      // STEP 6 — Verify indexes
      // --------------------------------------------------------

      final indexes =
          await dbV3.rawQuery(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index'
        ''',
      );

      final indexNames = indexes
          .map((row) => row['name'] as String)
          .toSet();

      const requiredIndexes = {
        'idx_posts_user_id',
        'idx_posts_created_at',
        'idx_posts_sync_status',
        'idx_users_sync_status',
      };

      if (!indexNames.containsAll(
        requiredIndexes,
      )) {
        throw Exception(
          'Required indexes are missing',
        );
      }

      messages.add(
        '✓ All indexes exist',
      );

      await dbV3.close();

      await deleteDatabase(path);

      messages.add(
        '✓ Migration test database cleaned',
      );

      return MigrationTestResult(
        success: true,
        messages: messages,
      );
    } catch (e) {
      return MigrationTestResult(
        success: false,
        messages: [
          ...messages,
          '✗ Migration test failed: $e',
        ],
      );
    }
  }

  static bool _hasColumn(
    List<Map<String, dynamic>> columns,
    String name,
  ) {
    return columns.any(
      (column) => column['name'] == name,
    );
  }

  static Future<void> _createV1Schema(
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
}