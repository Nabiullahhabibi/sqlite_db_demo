import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    super.id,
    required super.name,
    required super.email,
    required super.age,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      syncStatus:
      map['sync_status'] as String? ?? 'synced',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}