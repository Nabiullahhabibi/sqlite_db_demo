import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource(this.databaseHelper);

  Future<int> insertUser(UserModel user) async {
    final db = await databaseHelper.database;

    return db.insert(
      DatabaseConstants.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<UserModel>> getUsers() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.usersTable,
      orderBy: '${DatabaseConstants.columnId} DESC',
    );

    return result.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await databaseHelper.database;

    return db.update(
      DatabaseConstants.usersTable,
      user.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await databaseHelper.database;

    return db.delete(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // ------------------------------------------------------------
  // TRANSACTION
  // ------------------------------------------------------------

  Future<void> createUserWithFirstPost({
    required UserModel user,
    required PostModel post,
  }) async {
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // 1. Insert user
      final userId = await txn.insert(
        DatabaseConstants.usersTable,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // 2. Create post using generated user ID
      final postWithUserId = PostModel(
        userId: userId,
        title: post.title,
        body: post.body,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        syncStatus: post.syncStatus,
      );

      // 3. Insert post
      await txn.insert(
        DatabaseConstants.postsTable,
        postWithUserId.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }
}