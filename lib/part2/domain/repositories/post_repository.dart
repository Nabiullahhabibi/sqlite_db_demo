import '../entities/post.dart';

abstract class PostRepository {
  Future<int> insertPost(Post post);

  Future<List<Post>> getPostsByUser(int userId);

  Future<List<Post>> getPostsPaginated({
    required int page,
    required int pageSize,
  });

  Future<List<Map<String, dynamic>>> getPostsWithUsers();

  Future<List<Post>> getPendingPosts();

  Future<int> updatePost(Post post);

  Future<int> deletePost(int id);
}