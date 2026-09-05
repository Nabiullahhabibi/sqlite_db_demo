
/*
for part one
 */
// import 'package:flutter/material.dart';
// import 'package:sqlite_db_demo/part1/core/database/database_helper.dart';
// import 'package:sqlite_db_demo/part1/data/local/user_local_data_source.dart';
// import 'package:sqlite_db_demo/part1/data/repositories/user_repository_impl.dart';
// import 'package:sqlite_db_demo/part1/presentation/pages/sqlite_deom_page.dart';
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final databaseHelper = DatabaseHelper.instance;
//
//   final localDataSource = UserLocalDataSource(
//     databaseHelper: databaseHelper,
//   );
//
//   final repository = UserRepositoryImpl(
//     localDataSource: localDataSource,
//   );
//
//   runApp(
//     SqliteDemoApp(
//       repository: repository,
//     ),
//   );
// }
//
// class SqliteDemoApp extends StatelessWidget {
//   final UserRepositoryImpl repository;
//
//   const SqliteDemoApp({
//     super.key,
//     required this.repository,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SQLite Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.blue,
//         ),
//         useMaterial3: true,
//       ),
//       home: SqliteDemoPage(
//         repository: repository,
//       ),
//     );
//   }
// }


///////////////////////////////////////////////////

import 'package:flutter/material.dart';

import 'part2/core/database/database_helper.dart';
import 'part2/data/local/post_local_data_source.dart';
import 'part2/data/local/user_local_data_source.dart';
import 'part2/data/repositories/post_repository_impl.dart';
import 'part2/data/repositories/user_repository_impl.dart';
import 'part2/presentation/pages/posts_page.dart';
import 'part2/presentation/pages/users_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseHelper = DatabaseHelper.instance;

  await databaseHelper.database;

  final userLocalDataSource =
  UserLocalDataSource(
    databaseHelper,
  );

  final postLocalDataSource =
  PostLocalDataSource(
    databaseHelper,
  );

  final userRepository =
  UserRepositoryImpl(
    localDataSource: userLocalDataSource,
  );

  final postRepository =
  PostRepositoryImpl(
    localDataSource: postLocalDataSource,
  );

  runApp(
    MyApp(
      userRepository: userRepository,
      postRepository: postRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepositoryImpl userRepository;
  final PostRepositoryImpl postRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Part 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        userRepository: userRepository,
        postRepository: postRepository,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final UserRepositoryImpl userRepository;
  final PostRepositoryImpl postRepository;

  const HomePage({
    super.key,
    required this.userRepository,
    required this.postRepository,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      UsersPage(
        repository: widget.userRepository,
        postRepository: widget.postRepository,
      ),
      PostsPage(
        repository: widget.postRepository,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar:
      NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
        ],
      ),
    );
  }
}