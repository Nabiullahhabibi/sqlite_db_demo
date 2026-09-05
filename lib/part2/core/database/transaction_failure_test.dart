import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransactionTestResult {
  final bool success;
  final List<String> messages;

  const TransactionTestResult({
    required this.success,
    required this.messages,
  });
}

class TransactionFailureTest {
  TransactionFailureTest._();

  static Future<TransactionTestResult> run() async {
    final messages = <String>[];

    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'transaction_failure_test.db',
    );

    Database? db;

    try {
      // ----------------------------------------------------------
      // 1. Create a temporary database
      // ----------------------------------------------------------

      await deleteDatabase(path);

      db = await openDatabase(
        path,
        version: 1,
        onConfigure: (database) async {
          await database.execute(
            'PRAGMA foreign_keys = ON',
          );
        },
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE
            )
          ''');

          await database.execute('''
            CREATE TABLE posts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              title TEXT NOT NULL,

              FOREIGN KEY (user_id)
                REFERENCES users(id)
                ON DELETE CASCADE
            )
          ''');
        },
      );

      messages.add(
        '✓ Test database created',
      );

      // ----------------------------------------------------------
      // 2. Start transaction
      // ----------------------------------------------------------

      try {
        await db.transaction((txn) async {
          // Insert user
          final userId = await txn.insert(
            'users',
            {
              'name': 'Rollback User',
              'email': 'rollback@test.com',
            },
          );

          messages.add(
            '✓ User inserted inside transaction',
          );

          // ------------------------------------------------------
          // Force failure
          // ------------------------------------------------------

          messages.add(
            '✓ Simulating post insertion failure...',
          );

          throw Exception(
            'Simulated post insertion failure',
          );

          // This code intentionally never executes.
          //
          // await txn.insert(
          //   'posts',
          //   {
          //     'user_id': userId,
          //     'title': 'Test Post',
          //   },
          // );
        });
      } catch (e) {
        messages.add(
          '✓ Transaction failed as expected',
        );
      }

      // ----------------------------------------------------------
      // 3. Verify rollback
      // ----------------------------------------------------------

      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [
          'rollback@test.com',
        ],
      );

      if (users.isNotEmpty) {
        throw Exception(
          'Rollback failed: user still exists',
        );
      }

      messages.add(
        '✓ User was rolled back',
      );

      // ----------------------------------------------------------
      // 4. Verify posts
      // ----------------------------------------------------------

      final posts = await db.query(
        'posts',
      );

      if (posts.isNotEmpty) {
        throw Exception(
          'Rollback failed: post still exists',
        );
      }

      messages.add(
        '✓ No post was saved',
      );

      messages.add(
        '✓ Transaction rollback verified successfully',
      );

      return TransactionTestResult(
        success: true,
        messages: messages,
      );
    } catch (e) {
      return TransactionTestResult(
        success: false,
        messages: [
          ...messages,
          '✗ Transaction test failed: $e',
        ],
      );
    } finally {
      await db?.close();

      await deleteDatabase(path);
    }
  }
}