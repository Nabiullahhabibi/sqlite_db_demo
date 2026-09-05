import '../entities/post.dart';
import '../entities/user.dart';

class UserWithPosts {
  final User user;
  final List<Post> posts;

  const UserWithPosts({
    required this.user,
    required this.posts,
  });
}