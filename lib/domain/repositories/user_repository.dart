import '../entities/user.dart';

abstract class UserRepository {
  Future<int> createUser(User user);

  Future<List<User>> getUsers();

  Future<User?> getUserById(int id);

  Future<List<User>> searchUsers(String query);

  Future<int> updateUser(User user);

  Future<int> deleteUser(int id);

  Future<int> deleteAllUsers();

  Future<int> getUserCount();
}