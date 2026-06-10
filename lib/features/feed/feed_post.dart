class FeedPost {
  const FeedPost({
    required this.id,
    required this.username,
    required this.streakDay,
    required this.content,
    required this.reactionCount,
    required this.createdAt,
    this.isProgressCard = false,
  });

  final String id;
  final String username;
  final int streakDay;
  final String content;
  final int reactionCount;
  final DateTime createdAt;
  final bool isProgressCard;
}
