import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      syncStatus:
      map['sync_status'] as String? ?? 'synced',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}