import '../entities/user.dart';
import '../entities/post.dart';

abstract class UserRepository {
  Future<int> insertUser(User user);

  Future<List<User>> getUsers();

  Future<User?> getUserById(int id);

  Future<int> updateUser(User user);

  Future<int> deleteUser(int id);

  Future<void> createUserWithFirstPost({
    required User user,
    required Post post,
  });
}