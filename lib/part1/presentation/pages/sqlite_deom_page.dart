import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class SqliteDemoPage extends StatefulWidget {
  final UserRepository repository;

  const SqliteDemoPage({
    super.key,
    required this.repository,
  });

  @override
  State<SqliteDemoPage> createState() => _SqliteDemoPageState();
}

class _SqliteDemoPageState extends State<SqliteDemoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _searchController = TextEditingController();

  List<User> _users = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadUsers();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await widget.repository.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      await _loadUsers();
      return;
    }

    final users = await widget.repository.searchUsers(query);

    if (!mounted) return;

    setState(() {
      _users = users;
    });
  }

  Future<void> _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final age = int.tryParse(
      _ageController.text.trim(),
    );

    if (name.isEmpty ||
        email.isEmpty ||
        age == null) {
      _showMessage(
        'Please enter valid user information.',
      );
      return;
    }

    await widget.repository.createUser(
      User(
        name: name,
        email: email,
        age: age,
      ),
    );

    _clearForm();

    await _loadUsers();

    _showMessage('User created.');
  }

  Future<void> _updateUser(User user) async {
    final updatedUser = await showDialog<User>(
      context: context,
      builder: (dialogContext) {
        final nameController = TextEditingController(
          text: user.name,
        );

        final emailController = TextEditingController(
          text: user.email,
        );

        final ageController = TextEditingController(
          text: user.age.toString(),
        );

        return AlertDialog(
          title: const Text('Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final age = int.tryParse(
                  ageController.text.trim(),
                );

                if (name.isEmpty ||
                    email.isEmpty ||
                    age == null) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  User(
                    id: user.id,
                    name: name,
                    email: email,
                    age: age,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedUser == null) {
      return;
    }

    await widget.repository.updateUser(
      updatedUser,
    );

    if (!mounted) {
      return;
    }

    await _loadUsers();

    if (!mounted) {
      return;
    }

    _showMessage('User updated.');
  }
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Delete ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
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

    if (user.id == null) {
      return;
    }

    await widget.repository.deleteUser(
      user.id!,
    );

    await _loadUsers();

    _showMessage('User deleted.');
  }

  Future<void> _deleteAllUsers() async {
    if (_users.isEmpty) {
      _showMessage('There are no users.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete All'),
          content: const Text(
            'Delete all users?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await widget.repository.deleteAllUsers();

    await _loadUsers();

    _showMessage('All users deleted.');
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Demo'),
        actions: [
          IconButton(
            onPressed: _deleteAllUsers,
            icon: const Icon(
              Icons.delete_sweep,
            ),
            tooltip: 'Delete all',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCreateForm(),
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _createUser,
              icon: const Icon(Icons.add),
              label: const Text('Create User'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Search by name or email',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(Icons.clear),
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                user.name.isEmpty
                    ? '?'
                    : user.name[0].toUpperCase(),
              ),
            ),
            title: Text(user.name),
            subtitle: Text(
              '${user.email}\nAge: ${user.age}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _updateUser(user);
                }

                if (value == 'delete') {
                  _deleteUser(user);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }
}