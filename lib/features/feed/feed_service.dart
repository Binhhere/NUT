import 'feed_post.dart';

class FeedService {
  // TODO: Replace this in-memory service with a moderated Supabase-backed feed.
  final List<FeedPost> _posts = [];

  void ensureMockPosts(List<FeedPost> posts) {
    if (_posts.isNotEmpty) return;
    _posts.addAll(posts);
  }

  List<FeedPost> loadPosts() => List.unmodifiable(_posts);

  FeedPost createProgressPost(
    int streakDay, {
    required String defaultUsername,
    required String content,
    String? username,
  }) {
    final displayUsername =
        username?.trim().isEmpty ?? true ? defaultUsername : username!.trim();

    final post = FeedPost(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      username: displayUsername,
      streakDay: streakDay,
      content: content,
      reactionCount: 0,
      createdAt: DateTime.now(),
      isProgressCard: true,
    );

    _posts.insert(0, post);
    return post;
  }
}
