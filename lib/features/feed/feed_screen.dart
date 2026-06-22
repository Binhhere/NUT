import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/nut_pressable.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../streak/streak_model.dart';
import 'compose_screen.dart';
import 'feed_post.dart';
import 'feed_service.dart';
import 'quote_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.feedService,
    required this.streak,
    this.username,
  });

  final FeedService feedService;
  final StreakModel streak;
  final String? username;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<FeedPost> _posts = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.l10n;

    widget.feedService.ensureMockPosts([
      FeedPost(
        id: 'mock-1',
        username: l10n.feedMockUserSteady,
        streakDay: 12,
        content: l10n.feedMockPostSteady,
        reactionCount: 18,
        createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      FeedPost(
        id: 'mock-2',
        username: l10n.feedMockUserDayByDay,
        streakDay: 4,
        content: l10n.feedMockPostDayByDay,
        reactionCount: 9,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FeedPost(
        id: 'mock-3',
        username: l10n.feedMockUserClearMind,
        streakDay: 31,
        content: l10n.feedMockPostClearMind,
        reactionCount: 42,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);

    _posts = widget.feedService.loadPosts();
  }

  Future<void> _openComposeSheet() async {
    final l10n = context.l10n;
    final streakDay = widget.streak.currentStreakDays();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.nutPalette.surface,
      showDragHandle: true,
      builder: (context) {
        return ComposeProgressSheet(
          streakDay: streakDay,
          onPost: (content) {
            widget.feedService.createProgressPost(
              streakDay,
              defaultUsername: l10n.feedDefaultUsername,
              content: content,
              username: widget.username,
            );
            setState(() => _posts = widget.feedService.loadPosts());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.feedService.getQuoteOfTheDay();

    return Scaffold(
      body: NutResponsiveListView(
        children: [
          _FeedHeader(onPostProgress: _openComposeSheet),
          const SizedBox(height: NutSpacing.medium),
          _DailyWisdom(quote: quote),
          for (final post in _posts) ...[
            const SizedBox(height: NutSpacing.medium),
            _FeedPostCard(post: post),
          ],
        ],
      ),
    );
  }
}

class _DailyWisdom extends StatelessWidget {
  const _DailyWisdom({required this.quote});

  final DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return NutCard(
      padding: const EdgeInsets.all(20),
      color: palette.accentGold.withOpacity(0.05),
      borderColor: palette.accentGold.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: palette.accentGold, size: 24),
              const SizedBox(width: 8),
              Text(
                context.l10n.feedDailyWisdom,
                style: TextStyle(
                  color: palette.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "— ${quote.author}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.onPostProgress});

  final VoidCallback onPostProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SectionHeader(
                title: l10n.feedHeaderTitle,
                subtitle: l10n.feedHeaderSubtitle,
              ),
            ),
            NutPill(
              label: l10n.feedMembersPill,
              icon: Icons.people_outline,
            ),
          ],
        ),
        const SizedBox(height: NutSpacing.medium),
        Semantics(
          button: true,
          label: l10n.feedPostProgress,
          child: NutPressable(
            onTap: onPostProgress,
            enableHaptics: true,
            child: NutCard(
              padding: const EdgeInsets.all(14),
              borderColor: palette.accentBg,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.accentBg,
                      borderRadius: BorderRadius.circular(NutRadius.pill),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: palette.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: NutSpacing.medium),
                  Expanded(
                    child: Text(
                      l10n.feedComposePrompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(width: NutSpacing.small),
                  Tooltip(
                    message: l10n.feedPostProgress,
                    child: Icon(
                      Icons.add_circle_outline,
                      color: palette.accentGold,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return NutCard(
      padding: const EdgeInsets.all(16),
      borderColor: post.isProgressCard ? palette.accentBg : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      post.isProgressCard ? palette.accentBg : palette.surface,
                  borderRadius: BorderRadius.circular(NutRadius.pill),
                ),
                child: Center(
                  child: Text(
                    post.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: post.isProgressCard
                          ? palette.accentGold
                          : palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedUsername(post.username),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.feedDayMeta(
                        _formatCreatedAt(context, post.createdAt),
                        post.streakDay,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (post.isProgressCard)
                NutPill(
                  label: l10n.feedProgressPill,
                  icon: Icons.trending_up,
                ),
            ],
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: NutSpacing.medium),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(NutRadius.pill),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: palette.accentGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.feedReactionSupport(post.reactionCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCreatedAt(BuildContext context, DateTime createdAt) {
  final elapsed = DateTime.now().difference(createdAt);
  final l10n = context.l10n;

  if (elapsed.inMinutes < 1) return l10n.feedNow;
  if (elapsed.inMinutes < 60) return l10n.feedMinutesAgo(elapsed.inMinutes);
  if (elapsed.inHours < 24) return l10n.feedHoursAgo(elapsed.inHours);

  return l10n.feedDaysAgo(elapsed.inDays);
}
