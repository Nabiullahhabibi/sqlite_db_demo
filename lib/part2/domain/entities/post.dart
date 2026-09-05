class Post {
  final int? id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });
}