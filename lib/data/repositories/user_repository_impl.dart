import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/user_local_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<int> createUser(User user) {
    return localDataSource.insertUser(user);
  }

  @override
  Future<List<User>> getUsers() {
    return localDataSource.getUsers();
  }

  @override
  Future<User?> getUserById(int id) {
    return localDataSource.getUserById(id);
  }

  @override
  Future<List<User>> searchUsers(String query) {
    return localDataSource.searchUsers(query);
  }

  @override
  Future<int> updateUser(User user) {
    return localDataSource.updateUser(user);
  }

  @override
  Future<int> deleteUser(int id) {
    return localDataSource.deleteUser(id);
  }

  @override
  Future<int> deleteAllUsers() {
    return localDataSource.deleteAllUsers();
  }

  @override
  Future<int> getUserCount() {
    return localDataSource.getUserCount();
  }
}