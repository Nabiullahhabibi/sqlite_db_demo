class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'sqlite_part_2.db';

  static const int databaseVersion = 3;

  // Users
  static const String usersTable = 'users';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnAge = 'age';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  // Posts
  static const String postsTable = 'posts';

  static const String columnUserId = 'user_id';
  static const String columnTitle = 'title';
  static const String columnBody = 'body';
}