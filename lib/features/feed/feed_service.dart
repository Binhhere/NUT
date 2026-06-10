import 'feed_post.dart';

class FeedService {
  // TODO: Replace this in-memory service with a moderated Supabase-backed feed.
  final List<FeedPost> _posts = [
    FeedPost(
      id: 'mock-1',
      username: 'steady_fox',
      streakDay: 12,
      content: 'Made it through a difficult evening by going for a walk.',
      reactionCount: 18,
      createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
    FeedPost(
      id: 'mock-2',
      username: 'day_by_day',
      streakDay: 4,
      content: 'Checking in. Today I am keeping my phone out of bed.',
      reactionCount: 9,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FeedPost(
      id: 'mock-3',
      username: 'clear_mind',
      streakDay: 31,
      content:
          'Hit 30 days yesterday. The main change is feeling less reactive.',
      reactionCount: 42,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<FeedPost> loadPosts() => List.unmodifiable(_posts);

  FeedPost createProgressPost(int streakDay) {
    final post = FeedPost(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      username: 'you',
      streakDay: streakDay,
      content: 'I am protecting day $streakDay today.',
      reactionCount: 0,
      createdAt: DateTime.now(),
      isProgressCard: true,
    );

    _posts.insert(0, post);
    return post;
  }
}
