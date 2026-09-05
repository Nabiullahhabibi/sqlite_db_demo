import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/user_local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<int> insertUser(User user) {
    return localDataSource.insertUser(
      UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        age: user.age,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        syncStatus: user.syncStatus,
      ),
    );
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
  Future<int> updateUser(User user) {
    return localDataSource.updateUser(
      UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        age: user.age,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        syncStatus: user.syncStatus,
      ),
    );
  }

  @override
  Future<int> deleteUser(int id) {
    return localDataSource.deleteUser(id);
  }
}