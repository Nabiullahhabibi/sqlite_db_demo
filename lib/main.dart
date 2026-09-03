import 'package:flutter/material.dart';
import 'package:sqlite_db_demo/presentation/pages/sqlite_deom_page.dart';

import 'core/database/database_helper.dart';
import 'data/local/user_local_data_source.dart';
import 'data/repositories/user_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseHelper = DatabaseHelper.instance;

  final localDataSource = UserLocalDataSource(
    databaseHelper: databaseHelper,
  );

  final repository = UserRepositoryImpl(
    localDataSource: localDataSource,
  );

  runApp(
    SqliteDemoApp(
      repository: repository,
    ),
  );
}

class SqliteDemoApp extends StatelessWidget {
  final UserRepositoryImpl repository;

  const SqliteDemoApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: SqliteDemoPage(
        repository: repository,
      ),
    );
  }
}