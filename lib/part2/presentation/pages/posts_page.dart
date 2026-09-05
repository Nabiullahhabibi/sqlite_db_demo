import 'package:flutter/material.dart';

import '../../domain/repositories/post_repository.dart';

class PostsPage extends StatefulWidget {
  final PostRepository repository;

  const PostsPage({
    super.key,
    required this.repository,
  });

  @override
  State<PostsPage> createState() =>
      _PostsPageState();
}

class _PostsPageState
    extends State<PostsPage> {
  final ScrollController _scrollController =
  ScrollController();

  final List<Map<String, dynamic>> _posts = [];

  static const int _pageSize = 10;

  int _currentPage = 1;

  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );

    _loadNextPage();
  }

  // =========================
  // PAGINATION
  // =========================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final posts =
      await widget.repository
          .getPostsWithUsers();

      if (!mounted) {
        return;
      }

      setState(() {
        _posts
          ..clear()
          ..addAll(posts);

        _isLoading = false;
        _hasMore = false;
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

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    await _loadNextPage();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _onScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
      ),

      body: _isLoading && _posts.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _posts.isEmpty
          ? const Center(
        child: Text(
          'No posts found.',
        ),
      )
          : RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller:
          _scrollController,
          padding: const EdgeInsets.all(
            16,
          ),
          itemCount: _posts.length,
          itemBuilder: (
              context,
              index,
              ) {
            final post =
            _posts[index];

            return Card(
              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.person,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            post['user_name']
                            as String,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      post['post_title']
                      as String,
                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      post['post_body']
                      as String,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      post['post_created_at']
                      as String,
                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}