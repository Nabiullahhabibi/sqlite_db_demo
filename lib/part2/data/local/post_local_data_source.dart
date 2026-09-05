import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/post_model.dart';

// class PostLocalDataSource {
//   final DatabaseHelper databaseHelper;
//
//   PostLocalDataSource(this.databaseHelper);
//
//   Future<int> insertPost(PostModel post) async {
//     final db = await databaseHelper.database;
//
//     return db.insert(
//       DatabaseConstants.postsTable,
//       post.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.abort,
//     );
//   }
//
//   Future<List<PostModel>> getPostsByUser(
//       int userId,
//       ) async {
//     final db = await databaseHelper.database;
//
//     final result = await db.query(
//       DatabaseConstants.postsTable,
//       where: '${DatabaseConstants.columnUserId} = ?',
//       whereArgs: [userId],
//       orderBy:
//       '${DatabaseConstants.columnCreatedAt} DESC',
//     );
//
//     return result
//         .map(PostModel.fromMap)
//         .toList();
//   }
//
//   Future<int> updatePost(PostModel post) async {
//     final db = await databaseHelper.database;
//
//     return db.update(
//       DatabaseConstants.postsTable,
//       post.toMap(),
//       where: '${DatabaseConstants.columnId} = ?',
//       whereArgs: [post.id],
//     );
//   }
//
//   Future<int> deletePost(int id) async {
//     final db = await databaseHelper.database;
//
//     return db.delete(
//       DatabaseConstants.postsTable,
//       where: '${DatabaseConstants.columnId} = ?',
//       whereArgs: [id],
//     );
//   }
//
//   //  JOIN in Flutter
//   Future<List<Map<String, dynamic>>> getPostsWithUsers() async {
//     final db = await databaseHelper.database;
//
//     return db.rawQuery('''
//     SELECT
//       users.id AS user_id,
//       users.name AS user_name,
//       posts.id AS post_id,
//       posts.title,
//       posts.body,
//       posts.created_at
//     FROM users
//     INNER JOIN posts
//       ON users.id = posts.user_id
//     ORDER BY posts.created_at DESC
//   ''');
//   }
// }


import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/post_model.dart';

class PostLocalDataSource {
  final DatabaseHelper databaseHelper;

  PostLocalDataSource(this.databaseHelper);

  Future<int> insertPost(PostModel post) async {
    final db = await databaseHelper.database;

    return db.insert(
      DatabaseConstants.postsTable,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<PostModel>> getPostsByUser(
      int userId,
      ) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.postsTable,
      where: '${DatabaseConstants.columnUserId} = ?',
      whereArgs: [userId],
      orderBy:
      '${DatabaseConstants.columnCreatedAt} DESC',
    );

    return result.map(PostModel.fromMap).toList();
  }

  Future<List<PostModel>> getPostsPaginated({
    required int page,
    required int pageSize,
  }) async {
    final db = await databaseHelper.database;

    final offset = (page - 1) * pageSize;

    final result = await db.query(
      DatabaseConstants.postsTable,
      orderBy:
      '${DatabaseConstants.columnCreatedAt} DESC',
      limit: pageSize,
      offset: offset,
    );

    return result.map(PostModel.fromMap).toList();
  }

  Future<int> updatePost(PostModel post) async {
    final db = await databaseHelper.database;

    return db.update(
      DatabaseConstants.postsTable,
      post.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await databaseHelper.database;

    return db.delete(
      DatabaseConstants.postsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPostsWithUsers() async {
    final db = await databaseHelper.database;

    return db.rawQuery('''
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.email AS user_email,

        posts.id AS post_id,
        posts.title AS post_title,
        posts.body AS post_body,
        posts.created_at AS post_created_at

      FROM users

      INNER JOIN posts
        ON users.id = posts.user_id

      ORDER BY posts.created_at DESC
    ''');
  }

  Future<List<PostModel>> getPendingPosts() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.postsTable,
      where: '${DatabaseConstants.columnSyncStatus} = ?',
      whereArgs: ['pending'],
      orderBy:
      '${DatabaseConstants.columnCreatedAt} ASC',
    );

    return result.map(PostModel.fromMap).toList();
  }
}
/*
INNER JOIN

Only users who have posts:

SELECT *
FROM users
INNER JOIN posts
ON users.id = posts.user_id;
LEFT JOIN

All users, even users with zero posts:

SELECT
users.id,
users.name,
posts.title
FROM users
LEFT JOIN posts
ON users.id = posts.user_id;

Example:

Habibi    Flutter SQLite
Ahmad     Dart
Ali       NULL

Ali exists but has no post.

This is extremely useful in real applications.
    */
//////////////////////////////////
/*

17. Indexes

Imagine:

posts
1,000 rows
10,000 rows
100,000 rows
1,000,000 rows

We frequently search:

WHERE user_id = ?

Therefore:

CREATE INDEX idx_posts_user_id
ON posts(user_id);

Now SQLite can search the index instead of scanning the entire table.

18. When Should You Create Indexes?

Good candidates:

Foreign keys
Frequently searched columns
Frequently sorted columns
Frequently filtered columns
Unique lookup fields

For our application:

posts.user_id
posts.created_at
posts.sync_status
users.sync_status

are good candidates.

But don't blindly index everything.

Every index has a cost:

INSERT
UPDATE
DELETE

must also maintain the index.

19. Real-World Transaction

This is one of the most important parts of Part 2.

Suppose creating a user also creates their first post.

We need:

Create User
      ↓
Create Post

Both should succeed.

Or both should fail.

That's a transaction.

Future<void> createUserWithPost({
  required UserModel user,
  required PostModel post,
}) async {
  final db = await databaseHelper.database;

  await db.transaction((txn) async {
    final userId = await txn.insert(
      DatabaseConstants.usersTable,
      user.toMap(),
    );

    final postWithUser = PostModel(
      userId: userId,
      title: post.title,
      body: post.body,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      syncStatus: post.syncStatus,
    );

    await txn.insert(
      DatabaseConstants.postsTable,
      postWithUser.toMap(),
    );
  });
}

If something throws:

User insert
     ↓
Post insert ❌
     ↓
ROLLBACK

The user insertion is rolled back too.

20. Why Transactions Matter

Without transaction:

Insert User       ✅
Insert Post       ❌

Database:

User exists
Post doesn't exist

Potentially inconsistent state.

With transaction:

BEGIN
   ↓
Insert User
   ↓
Insert Post
   ↓
COMMIT

or:

BEGIN
   ↓
Insert User
   ↓
Insert Post ❌
   ↓
ROLLBACK

This is the behavior you want for related operations.

21. Pagination

Never do this for a huge database:

db.query('posts');

and load 500,000 records.

Instead:

Page 1 → 20 posts
Page 2 → 20 posts
Page 3 → 20 posts

SQLite:

LIMIT 20
OFFSET 40

means:

skip 40
take 20
22. Pagination Implementation
Future<List<PostModel>> getPostsPaginated({
  required int page,
  required int pageSize,
}) async {
  final db = await databaseHelper.database;

  final offset = (page - 1) * pageSize;

  final result = await db.query(
    DatabaseConstants.postsTable,
    orderBy:
        '${DatabaseConstants.columnCreatedAt} DESC',
    limit: pageSize,
    offset: offset,
  );

  return result
      .map(PostModel.fromMap)
      .toList();
}

Usage:

final page1 = await getPostsPaginated(
  page: 1,
  pageSize: 20,
);

final page2 = await getPostsPaginated(
  page: 2,
  pageSize: 20,
);
23. Senior Pagination Note

OFFSET pagination is simple and good for learning and many applications.

For very large, frequently changing datasets, consider keyset/cursor pagination.

Instead of:

OFFSET 10000

you can use something like:

WHERE id < ?
ORDER BY id DESC
LIMIT 20

This can scale better.

For this demo, keep LIMIT/OFFSET because it clearly teaches SQLite pagination.

 ////////////////////////

 24. Database Migrations

This is another major senior concept.

Imagine your application originally shipped with:

Database v1

Later you need:

updated_at

You cannot simply recreate the database because users already have data.

Therefore:

v1
 ↓
v2
 ↓
v3
25. Version 1

Original:

users
────────────────
id
name
email
age
created_at

Database:

version: 1
26. Version 2

We add:

updated_at

Migration:

Future<void> _upgradeToV2(Database db) async {
  await db.execute('''
    ALTER TABLE users
    ADD COLUMN updated_at TEXT
  ''');

  await db.execute('''
    UPDATE users
    SET updated_at = created_at
  ''');
}

Then:

v1 → v2
27. Version 3

Now add:

sync_status

Migration:

Future<void> _upgradeToV3(Database db) async {
  await db.execute('''
    ALTER TABLE users
    ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'
  ''');

  await db.execute('''
    CREATE INDEX idx_users_sync_status
    ON users(sync_status)
  ''');
}

Now:

v1
 ↓
v2
 ↓
v3
28. Important Migration Rule

Don't do this:

if (oldVersion < 2) {
   ...
}

if (oldVersion < 3) {
   ...
}

by thinking only about the final version.

Actually, the sequential checks are exactly what we want.

If user has:

v1

and current version is:

v3

then:

_upgradeToV2()
      ↓
_upgradeToV3()

runs.

If user already has:

v2

then only:

_upgradeToV3()

runs.

This is why migrations must be incremental.

29. Migration Rules You Should Remember

Never casually:

delete database
recreate database

in production.

Instead:

v1 → v2
v2 → v3
v3 → v4

Each migration should be:

small
predictable
testable
backward-aware

And you should test upgrades from old versions.
 */
