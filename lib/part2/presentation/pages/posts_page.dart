import 'package:flutter/material.dart';

import '../../domain/entities/post_with_user.dart';
import '../../domain/repositories/post_repository.dart';

class PostsPage extends StatefulWidget {
  final PostRepository repository;

  const PostsPage({
    super.key,
    required this.repository,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  static const int _pageSize = 10;

  final List<PostWithUser> _posts = [];

  int _currentPage = 1;

  bool _isLoading = false;
  bool _hasMore = true;

  final ScrollController _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    _loadNextPage();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
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
      final newPosts =
          await widget.repository.getPostsWithUsersPaginated(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts.addAll(newPosts);

        _currentPage++;

        if (newPosts.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load posts: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _posts.isEmpty && _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _posts.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'No posts found',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount:
                        _posts.length +
                        (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      final item = _posts[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              item.user.name.isNotEmpty
                                  ? item.user.name[0]
                                      .toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(
                            item.post.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.user.name}\n'
                            '${item.post.body}',
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing:
                              _buildSyncIcon(
                            item.post.syncStatus,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget? _buildSyncIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.sync);

      case 'failed':
        return const Icon(
          Icons.error_outline,
        );

      case 'conflict':
        return const Icon(
          Icons.warning_amber,
        );

      default:
        return const Icon(
          Icons.check_circle_outline,
        );
    }
  }
}