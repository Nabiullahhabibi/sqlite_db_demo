import 'post.dart';
import 'user.dart';

class PostWithUser {
  final Post post;
  final User user;

  const PostWithUser({
    required this.post,
    required this.user,
  });
}