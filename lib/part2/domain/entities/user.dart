class User {
  final int? id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });
}