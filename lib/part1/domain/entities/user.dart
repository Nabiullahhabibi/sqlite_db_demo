class User {
  final int? id;
  final String name;
  final String email;
  final int age;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'age: $age'
        ')';
  }
}