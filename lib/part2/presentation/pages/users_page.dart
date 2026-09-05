import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../widgets/user_card.dart';
import 'user_posts_page.dart';

class UsersPage extends StatefulWidget {
  final UserRepository repository;
  final PostRepository postRepository;

  const UsersPage({
    super.key,
    required this.repository,
    required this.postRepository,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> _users = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // =========================
  // LOAD USERS
  // =========================

  Future<void> _loadUsers() async {
    try {
      final users = await widget.repository.getUsers();

      if (!mounted) {
        return;
      }

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load users: $e',
      );
    }
  }

  // =========================
  // CREATE USER
  // =========================

  Future<void> _createUser() async {
    final result = await showDialog<UserFormResult>(
      context: context,
      builder: (dialogContext) {
        return const _UserFormDialog();
      },
    );

    if (result == null) {
      return;
    }

    try {
      final now = DateTime.now();

      final user = User(
        name: result.name,
        email: result.email,
        age: result.age,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await widget.repository.insertUser(user);

      if (!mounted) {
        return;
      }

      await _loadUsers();

      if (!mounted) {
        return;
      }

      _showMessage('User created successfully.');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to create user: $e',
      );
    }
  }

  // =========================
  // DELETE USER
  // =========================

  Future<void> _deleteUser(User user) async {
    if (user.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Delete ${user.name}?\n\n'
                'All posts belonging to this user '
                'will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await widget.repository.deleteUser(
        user.id!,
      );

      if (!mounted) {
        return;
      }

      await _loadUsers();

      if (!mounted) {
        return;
      }

      _showMessage(
        'User deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to delete user: $e',
      );
    }
  }

  // =========================
  // OPEN USER POSTS
  // =========================

  Future<void> _openUserPosts(User user) async {
    if (user.id == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return UserPostsPage(
            user: user,
            repository: widget.postRepository
          );
        },
      ),
    );
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Create User'),
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _users.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            100,
          ),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];

            return UserCard(
              user: user,
              onTap: () {
                _openUserPosts(user);
              },
              onDelete: () {
                _deleteUser(user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
            ),

            const SizedBox(height: 16),

            const Text(
              'No users found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Create your first user to get started.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _createUser,
              icon: const Icon(Icons.person_add),
              label: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// USER FORM RESULT
// =====================================================

class UserFormResult {
  final String name;
  final String email;
  final int age;

  const UserFormResult({
    required this.name,
    required this.email,
    required this.age,
  });
}

// =====================================================
// USER FORM DIALOG
// =====================================================

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog();

  @override
  State<_UserFormDialog> createState() =>
      _UserFormDialogState();
}

class _UserFormDialogState
    extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _ageController =
  TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = UserFormResult(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.parse(
        _ageController.text.trim(),
      ),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User'),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction:
                TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter a name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter an email';
                  }

                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _ageController,
                keyboardType:
                TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  final age = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (age == null) {
                    return 'Enter a valid age';
                  }

                  if (age <= 0) {
                    return 'Age must be greater than 0';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}