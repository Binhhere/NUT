import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';
import '../streak/streak_model.dart';
import 'feed_post.dart';
import 'feed_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.feedService,
    required this.streak,
  });

  final FeedService feedService;
  final StreakModel streak;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late List<FeedPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = widget.feedService.loadPosts();
  }

  void _postProgress() {
    widget.feedService.createProgressPost(widget.streak.currentStreakDays());
    setState(() => _posts = widget.feedService.loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'People are trying with you.',
                  subtitle:
                      'Text-first community posts. No login or backend yet.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _postProgress,
                  icon: const Icon(Icons.add_card),
                  label: const Text('Post progress'),
                ),
              ],
            );
          }

          return _FeedPostCard(post: _posts[index - 1]);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _posts.length + 1,
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: post.isProgressCard
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  child: Text(
                    post.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: post.isProgressCard
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${post.username}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'Day ${post.streakDay}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (post.isProgressCard)
                  Chip(
                    label: const Text('Progress'),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    backgroundColor: colorScheme.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.favorite_border,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text('${post.reactionCount} support'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
