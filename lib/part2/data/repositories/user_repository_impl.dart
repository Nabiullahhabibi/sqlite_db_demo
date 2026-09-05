import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/user_local_data_source.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<int> insertUser(User user) async {
    final model = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      syncStatus: user.syncStatus,
    );

    return localDataSource.insertUser(model);
  }

  @override
  Future<List<User>> getUsers() async {
    return localDataSource.getUsers();
  }

  @override
  Future<User?> getUserById(int id) async {
    return localDataSource.getUserById(id);
  }

  @override
  Future<int> updateUser(User user) async {
    final model = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      syncStatus: user.syncStatus,
    );

    return localDataSource.updateUser(model);
  }

  @override
  Future<int> deleteUser(int id) async {
    return localDataSource.deleteUser(id);
  }

  @override
  Future<void> createUserWithFirstPost({
    required User user,
    required Post post,
  }) async {
    final userModel = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      syncStatus: user.syncStatus,
    );

    final postModel = PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      body: post.body,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      syncStatus: post.syncStatus,
    );

    await localDataSource.createUserWithFirstPost(
      user: userModel,
      post: postModel,
    );
  }
}