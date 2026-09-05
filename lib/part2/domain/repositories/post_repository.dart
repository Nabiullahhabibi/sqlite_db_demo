import '../entities/post.dart';
import '../entities/post_with_user.dart';

abstract class PostRepository {
  Future<int> insertPost(Post post);

  Future<List<Post>> getPostsByUser(int userId);

  Future<List<Post>> getPostsPaginated({
    required int page,
    required int pageSize,
  });

  Future<List<PostWithUser>> getPostsWithUsersPaginated({
    required int page,
    required int pageSize,
  });

  Future<List<Map<String, dynamic>>> getPostsWithUsers();

  Future<List<Post>> getPendingPosts();

  Future<int> updatePost(Post post);

  Future<int> deletePost(int id);
}