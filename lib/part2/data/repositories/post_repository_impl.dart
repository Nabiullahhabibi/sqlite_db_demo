import 'package:sqlite_db_demo/part2/domain/entities/post_with_user.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../local/post_local_data_source.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource localDataSource;

  PostRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<int> insertPost(Post post) {
    return localDataSource.insertPost(
      PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        syncStatus: post.syncStatus,
      ),
    );
  }

  @override
  Future<List<Post>> getPostsByUser(int userId) {
    return localDataSource.getPostsByUser(userId);
  }

  @override
  Future<List<Post>> getPostsPaginated({
    required int page,
    required int pageSize,
  }) {
    return localDataSource.getPostsPaginated(
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPostsWithUsers() {
    return localDataSource.getPostsWithUsers();
  }

  @override
  Future<List<Post>> getPendingPosts() {
    return localDataSource.getPendingPosts();
  }

  @override
  Future<int> updatePost(Post post) {
    return localDataSource.updatePost(
      PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        syncStatus: post.syncStatus,
      ),
    );
  }

  @override
  Future<int> deletePost(int id) {
    return localDataSource.deletePost(id);
  }

  @override
Future<List<PostWithUser>> getPostsWithUsersPaginated({
  required int page,
  required int pageSize,
}) async {
  return localDataSource.getPostsWithUsersPaginated(
    page: page,
    pageSize: pageSize,
  );
}
}