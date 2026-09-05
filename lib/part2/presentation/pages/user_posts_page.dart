import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';
import '../widgets/post_card.dart';

class UserPostsPage extends StatefulWidget {
  final User user;
  final PostRepository repository;

  const UserPostsPage({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  State<UserPostsPage> createState() =>
      _UserPostsPageState();
}

class _UserPostsPageState
    extends State<UserPostsPage> {
  List<Post> _posts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadPosts();
  }

  // =========================
  // LOAD POSTS
  // =========================

  Future<void> _loadPosts() async {
    if (widget.user.id == null) {
      return;
    }

    try {
      final posts =
      await widget.repository.getPostsByUser(
        widget.user.id!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = posts;
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
        'Failed to load posts: $e',
      );
    }
  }

  // =========================
  // CREATE POST
  // =========================

  Future<void> _createPost() async {
    final result =
    await showDialog<PostFormResult>(
      context: context,
      builder: (_) {
        return const _PostFormDialog();
      },
    );

    if (result == null) {
      return;
    }

    if (widget.user.id == null) {
      return;
    }

    try {
      final now = DateTime.now();

      final post = Post(
        userId: widget.user.id!,
        title: result.title,
        body: result.body,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await widget.repository.insertPost(
        post,
      );

      if (!mounted) {
        return;
      }

      await _loadPosts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Post created successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to create post: $e',
      );
    }
  }

  // =========================
  // UPDATE POST
  // =========================

  Future<void> _updatePost(Post post) async {
    final result =
    await showDialog<PostFormResult>(
      context: context,
      builder: (_) {
        return _PostFormDialog(
          initialTitle: post.title,
          initialBody: post.body,
          title: 'Update Post',
          submitText: 'Update',
        );
      },
    );

    if (result == null) {
      return;
    }

    if (post.id == null) {
      return;
    }

    try {
      final updatedPost = Post(
        id: post.id,
        userId: post.userId,
        title: result.title,
        body: result.body,
        createdAt: post.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await widget.repository.updatePost(
        updatedPost,
      );

      if (!mounted) {
        return;
      }

      await _loadPosts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Post updated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to update post: $e',
      );
    }
  }

  // =========================
  // DELETE POST
  // =========================

  Future<void> _deletePost(Post post) async {
    if (post.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  true,
                );
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
      await widget.repository.deletePost(
        post.id!,
      );

      if (!mounted) {
        return;
      }

      await _loadPosts();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Post deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to delete post: $e',
      );
    }
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
        title: Text(
          '${widget.user.name}\'s Posts',
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _posts.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            100,
          ),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];

            return PostCard(
              post: post,
              onTap: () {
                _updatePost(post);
              },
              onDelete: () {
                _deletePost(post);
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
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 80,
            ),

            const SizedBox(height: 16),

            const Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${widget.user.name} has not created any posts.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _createPost,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// POST FORM RESULT
// =====================================================

class PostFormResult {
  final String title;
  final String body;

  const PostFormResult({
    required this.title,
    required this.body,
  });
}

// =====================================================
// POST FORM DIALOG
// =====================================================

class _PostFormDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialBody;
  final String title;
  final String submitText;

  const _PostFormDialog({
    this.initialTitle,
    this.initialBody,
    this.title = 'Create Post',
    this.submitText = 'Create',
  });

  @override
  State<_PostFormDialog> createState() =>
      _PostFormDialogState();
}

class _PostFormDialogState
    extends State<_PostFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController
  _titleController;

  late final TextEditingController
  _bodyController;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
          text: widget.initialTitle ?? '',
        );

    _bodyController =
        TextEditingController(
          text: widget.initialBody ?? '',
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = PostFormResult(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction:
                TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter a title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _bodyController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  prefixIcon:
                  Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter post content';
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
          child: Text(widget.submitText),
        ),
      ],
    );
  }
}