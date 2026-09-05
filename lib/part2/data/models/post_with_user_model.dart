import 'package:sqlite_db_demo/part2/domain/entities/post_with_user.dart';

import 'post_model.dart';
import 'user_model.dart';

class PostWithUserModel extends PostWithUser {
  const PostWithUserModel({
    required super.post,
    required super.user,
  });

  factory PostWithUserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final post = PostModel(
      id: map['post_id'] as int,
      userId: map['post_user_id'] as int,
      title: map['post_title'] as String,
      body: map['post_body'] as String,
      createdAt: DateTime.parse(
        map['post_created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['post_updated_at'] as String,
      ),
      syncStatus: map['post_sync_status'] as String? ?? 'synced',
    );

    final user = UserModel(
      id: map['user_id'] as int,
      name: map['user_name'] as String,
      email: map['user_email'] as String,
      age: map['user_age'] as int,
      createdAt: DateTime.parse(
        map['user_created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['user_updated_at'] as String,
      ),
      syncStatus: map['user_sync_status'] as String? ?? 'synced',
    );

    return PostWithUserModel(
      post: post,
      user: user,
    );
  }
}