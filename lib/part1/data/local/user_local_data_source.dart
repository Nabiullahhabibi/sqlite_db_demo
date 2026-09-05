import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/user.dart';

class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource({
    required this.databaseHelper,
  });

  Future<int> insertUser(User user) async {
    final db = await databaseHelper.database;

    return db.insert(
      DatabaseConstants.usersTable,
      _toMap(user),
    );
  }

  Future<List<User>> getUsers() async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      DatabaseConstants.usersTable,
      orderBy: '${DatabaseConstants.columnId} DESC',
    );

    return rows.map(_fromMap).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _fromMap(rows.first);
  }

  Future<List<User>> searchUsers(String query) async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      DatabaseConstants.usersTable,
      where: '''
        ${DatabaseConstants.columnName} LIKE ?
        OR ${DatabaseConstants.columnEmail} LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
      ],
      orderBy: '${DatabaseConstants.columnName} ASC',
    );

    return rows.map(_fromMap).toList();
  }

  Future<int> updateUser(User user) async {
    if (user.id == null) {
      throw ArgumentError(
        'Cannot update a user without an id.',
      );
    }

    final db = await databaseHelper.database;

    return db.update(
      DatabaseConstants.usersTable,
      _toMap(user),
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

  Future<int> deleteAllUsers() async {
    final db = await databaseHelper.database;

    return db.delete(
      DatabaseConstants.usersTable,
    );
  }

  Future<int> getUserCount() async {
    final db = await databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM ${DatabaseConstants.usersTable}
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Map<String, dynamic> _toMap(User user) {
    return {
      if (user.id != null)
        DatabaseConstants.columnId: user.id,
      DatabaseConstants.columnName: user.name,
      DatabaseConstants.columnEmail: user.email,
      DatabaseConstants.columnAge: user.age,
    };
  }

  User _fromMap(Map<String, dynamic> map) {
    return User(
      id: map[DatabaseConstants.columnId] as int?,
      name: map[DatabaseConstants.columnName] as String,
      email: map[DatabaseConstants.columnEmail] as String,
      age: map[DatabaseConstants.columnAge] as int,
    );
  }
}