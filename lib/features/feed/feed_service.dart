import 'feed_post.dart';
import 'quote_model.dart';

class FeedService {
  // 30 quotes — cycles daily via dayOfYear % 30.
  // Mix: original NUT copy, public-domain / paraphrased attributions.
  // Avoid clinical language; keep tone calm, steady, non-preachy.
  final List<DailyQuote> _quotes = const [
    DailyQuote(
      text: 'You do not need intensity. You need one protected choice.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Discipline is choosing between what you want now and what you want most.',
      author: 'Abraham Lincoln',
    ),
    DailyQuote(
      text: 'The best time to plant a tree was twenty years ago. The second best time is now.',
      author: 'Chinese Proverb',
    ),
    DailyQuote(
      text: 'Your next choice is the only one that matters.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Small wins daily lead to lasting results over time.',
      author: 'Robin Sharma',
    ),
    DailyQuote(
      text: 'Strength does not come from winning. Your struggles develop your strengths.',
      author: 'Arnold Schwarzenegger',
    ),
    DailyQuote(
      text: 'He who has a why to live can bear almost any how.',
      author: 'Friedrich Nietzsche',
    ),
    DailyQuote(
      text: 'You are not your urge. You are the person who chooses what to do next.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'A man who masters himself can be trusted.',
      author: 'Marcus Aurelius',
    ),
    DailyQuote(
      text: 'Every moment of resistance is a vote for the person you are becoming.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'We are what we repeatedly do. Excellence is not an act but a habit.',
      author: 'Aristotle',
    ),
    DailyQuote(
      text: 'It does not matter how slowly you go, as long as you do not stop.',
      author: 'Confucius',
    ),
    DailyQuote(
      text: 'The secret of getting ahead is getting started.',
      author: 'Mark Twain',
    ),
    DailyQuote(
      text: 'Protect the next hour. The day will follow.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'First, forget inspiration. Habit is more dependable.',
      author: 'Octavia Butler',
    ),
    DailyQuote(
      text: 'Between stimulus and response there is a space. In that space is your power.',
      author: 'Viktor Frankl',
    ),
    DailyQuote(
      text: 'One day at a time is not a cliché. It is the only honest unit of measurement.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Do not wish it were easier. Wish you were better.',
      author: 'Jim Rohn',
    ),
    DailyQuote(
      text: 'The body achieves what the mind believes.',
      author: 'Napoleon Hill',
    ),
    DailyQuote(
      text: 'Quiet effort accumulates faster than loud motivation.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Knowing yourself is the beginning of all wisdom.',
      author: 'Aristotle',
    ),
    DailyQuote(
      text: 'An unexamined life is not worth living.',
      author: 'Socrates',
    ),
    DailyQuote(
      text: 'You have power over your mind, not outside events. Realise this and you will find strength.',
      author: 'Marcus Aurelius',
    ),
    DailyQuote(
      text: 'The cave you fear to enter holds the treasure you seek.',
      author: 'Joseph Campbell',
    ),
    DailyQuote(
      text: 'Relapse is not the end of the story. It is part of the data.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Fall seven times, stand up eight.',
      author: 'Japanese Proverb',
    ),
    DailyQuote(
      text: 'Suffer the pain of discipline or suffer the pain of regret.',
      author: 'Jim Rohn',
    ),
    DailyQuote(
      text: 'The most important conversation you will have today is the one with yourself.',
      author: 'NUT',
    ),
    DailyQuote(
      text: 'Nothing in the world can take the place of persistence.',
      author: 'Calvin Coolidge',
    ),
    DailyQuote(
      text: 'Today\'s effort is tomorrow\'s baseline.',
      author: 'NUT',
    ),
  ];

  DailyQuote getQuoteOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

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
