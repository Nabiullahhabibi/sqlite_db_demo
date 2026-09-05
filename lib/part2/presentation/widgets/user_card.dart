import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            user.name.isNotEmpty
                ? user.name[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(user.name),
        subtitle: Text(
          '${user.email}\nAge: ${user.age}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}