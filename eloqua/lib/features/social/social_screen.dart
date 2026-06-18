import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/feed_service.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../share/share_screen.dart';
import 'circuit_leaderboard_screen.dart';

// ── Paradise color constants ──────────────────────────────────────────────────
const _pFuchsia = Color(0xFFE8407A);
const _pOrange = Color(0xFFD4561E);
const _pGreen = Color(0xFF2E9E56);
const _pTurquoise = Color(0xFF3AAAB8);
const _pYellow = Color(0xFFFAE640);
const _pCream = Color(0xFFFFF5E0);
const _pBrown = Color(0xFF2C1A0E);
const _pOrchid = Color(0xFF9B4DB5);
const _pWhite = Color(0xFFFFFFFF);

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    final auth = context.watch<AuthService>();
    final feed = context.watch<FeedService>();
    final posts = feed.posts;

    final myLatest =
        posts.where((p) => p.userName == auth.currentUserName).isNotEmpty
            ? posts.firstWhere((p) => p.userName == auth.currentUserName)
            : null;

    return Scaffold(
      backgroundColor: isParadise ? _pCream : cs.surface,
      body: SafeArea(
        child: Column(children: [
          _TopBar(
            isParadise: isParadise,
            onLeaderboard: () => Navigator.pushNamed(context, '/circuit'),
          ),
          _ShareBar(
            userName: auth.currentUserName ?? 'S',
            latestPost: myLatest,
            isParadise: isParadise,
          ),
          if (posts.isEmpty)
            Expanded(child: _EmptyFeed(isParadise: isParadise))
          else
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, i) => _PostCard(
                  post: posts[i],
                  timeAgo: _timeAgo(posts[i].postedAt),
                  isParadise: isParadise,
                  currentUserName: auth.currentUserName ?? '',
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Custom Top Bar ────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isParadise;
  final VoidCallback onLeaderboard;

  const _TopBar({required this.isParadise, required this.onLeaderboard});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: cs.primary,
        boxShadow: [
          BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.primaryContainer, width: 1.5),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Text('COMMUNITY FEED',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onPrimary,
                letterSpacing: 3.0)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticService.instance.light();
            onLeaderboard();
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
              border:
                  Border.all(color: cs.onPrimary.withOpacity(0.4), width: 1.0),
            ),
            child:
                Icon(Icons.leaderboard_rounded, size: 18, color: cs.onPrimary),
          ),
        ),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyFeed extends StatelessWidget {
  final bool isParadise;
  const _EmptyFeed({required this.isParadise});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isParadise
                  ? _pFuchsia.withOpacity(0.1)
                  : cs.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isParadise ? Icons.filter_vintage_rounded : Icons.people_outline,
              size: 48,
              color: isParadise
                  ? _pOrchid.withOpacity(0.6)
                  : cs.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nothing posted yet',
            style: isParadise
                ? GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: _pBrown)
                : tt.headlineSmall?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            'Complete a session and hit "Post to Community Feed" on the share screen.',
            textAlign: TextAlign.center,
            style: isParadise
                ? GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _pBrown.withOpacity(0.6),
                    height: 1.5)
                : tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.8), height: 1.5),
          ),
        ]),
      ),
    );
  }
}

// ── Share bar ─────────────────────────────────────────────────────────────────
class _ShareBar extends StatelessWidget {
  final String userName;
  final FeedPost? latestPost;
  final bool isParadise;

  const _ShareBar(
      {required this.userName,
      required this.latestPost,
      required this.isParadise});

  void _onTap(BuildContext context) {
    if (latestPost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete a session and share it to post here!'),
          backgroundColor: isParadise ? _pFuchsia : context.cs.primary,
        ),
      );
      return;
    }
    final p = latestPost!;
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ShareScreen(
            overall: p.overall,
            clarity: p.clarity,
            pacing: p.pacing,
            grammar: p.grammar,
            confidence: p.confidence,
            topicTitle: p.topicTitle,
            duration: p.duration,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isParadise ? _pWhite : cs.surface,
        border: Border(
          bottom: BorderSide(
            color: isParadise ? _pOrange.withOpacity(0.2) : cs.outlineVariant,
            width: isParadise ? 2.0 : 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
              color: isParadise
                  ? _pOrange.withOpacity(0.05)
                  : cs.shadow.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isParadise ? _pTurquoise : cs.primaryContainer,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
            style: TextStyle(
              fontFamily: isParadise ? null : 'Georgia',
              color: isParadise ? _pWhite : cs.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => _onTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isParadise
                    ? _pTurquoise.withOpacity(0.05)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: isParadise
                    ? Border.all(
                        color: _pTurquoise.withOpacity(0.3), width: 1.5)
                    : Border.all(color: cs.outlineVariant, width: 1.0),
              ),
              child: Text(
                latestPost != null
                    ? 'Share your latest score...'
                    : 'Complete a session to share your score...',
                style: isParadise
                    ? GoogleFonts.nunito(
                        color: _pTurquoise.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic)
                    : TextStyle(
                        color: cs.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Post card ─────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final FeedPost post;
  final String timeAgo;
  final bool isParadise;
  final String currentUserName;

  const _PostCard(
      {required this.post,
      required this.timeAgo,
      required this.isParadise,
      required this.currentUserName});

  String get _actionLabel {
    if (post.overall >= 90) return 'scored ${post.overall} 🔥';
    if (post.overall >= 75) return 'scored ${post.overall}';
    return 'completed a session · ${post.overall} pts';
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDetailSheet(post: post, isParadise: isParadise),
    );
  }

  void _openComments(BuildContext context) {
    final auth = context.read<AuthService>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: post,
        currentUserName: auth.currentUserName ?? 'S',
        isParadise: isParadise,
      ),
    );
  }

  void _sharePost(BuildContext context) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ShareScreen(
            overall: post.overall,
            clarity: post.clarity,
            pacing: post.pacing,
            grammar: post.grammar,
            confidence: post.confidence,
            topicTitle: post.topicTitle,
            duration: post.duration,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final feed = context.read<FeedService>();

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isParadise ? _pWhite : cs.surface,
          borderRadius: BorderRadius.circular(isParadise ? 24 : 20),
          border: Border.all(
            color: isParadise
                ? _pOrange.withOpacity(0.6)
                : cs.outline.withOpacity(0.12),
            width: isParadise ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
                color: isParadise
                    ? _pOrange.withOpacity(0.1)
                    : cs.shadow.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isParadise ? _pYellow : cs.primaryContainer,
              child: Text(
                post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'S',
                style: TextStyle(
                    fontFamily: isParadise ? null : 'Georgia',
                    fontWeight: FontWeight.w800,
                    color: isParadise ? _pBrown : cs.onPrimaryContainer,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: isParadise
                          ? GoogleFonts.nunito(fontSize: 15, color: _pBrown)
                          : tt.bodyMedium?.copyWith(color: cs.onSurface),
                      children: [
                        TextSpan(
                          text: post.userName,
                          style: isParadise
                              ? GoogleFonts.oswald(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5)
                              : const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' $_actionLabel',
                          style: isParadise
                              ? TextStyle(
                                  color: _pBrown.withOpacity(0.7),
                                  fontStyle: FontStyle.italic)
                              : TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: isParadise
                        ? GoogleFonts.barlowCondensed(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _pTurquoise,
                            letterSpacing: 1.0)
                        : tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            if (post.userName == currentUserName)
              GestureDetector(
                onTap: () async {
                  HapticService.instance.selection();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor:
                          isParadise ? _pCream : context.cs.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        'Delete post?',
                        style: isParadise
                            ? GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                                color: _pBrown)
                            : null,
                      ),
                      content: Text(
                        'This will permanently remove your post from the community feed.',
                        style: isParadise
                            ? GoogleFonts.nunito(
                                color: _pBrown.withOpacity(0.7))
                            : null,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: isParadise
                                      ? _pTurquoise
                                      : context.cs.primary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Delete',
                              style: TextStyle(
                                  color: isParadise
                                      ? _pFuchsia
                                      : context.cs.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<FeedService>().deletePost(post.id);
                  }
                },
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: isParadise
                      ? _pOrange
                      : context.cs.onSurfaceVariant.withOpacity(0.5),
                ),
              )
            else
              Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: isParadise
                    ? _pOrange
                    : cs.onSurfaceVariant.withOpacity(0.5),
              ),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isParadise ? _pCream : cs.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: isParadise
                  ? Border.all(color: _pTurquoise.withOpacity(0.4), width: 1.5)
                  : Border.all(color: cs.outline.withOpacity(0.08), width: 1.0),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                post.topicTitle,
                style: isParadise
                    ? GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        color: _pBrown,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        height: 1.3)
                    : tt.titleMedium?.copyWith(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(children: [
                _Chip(label: post.persona, isParadise: isParadise),
                const SizedBox(width: 8),
                _Chip(label: post.duration, isParadise: isParadise),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            _Action(
              icon: post.likedByMe
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: '${post.likes}',
              active: post.likedByMe,
              isParadise: isParadise,
              onTap: () {
                feed.toggleLike(post.id);
                HapticService.instance.light();
              },
            ),
            const SizedBox(width: 24),
            _Action(
              icon: Icons.chat_bubble_outline_rounded,
              label: '${post.comments.length}',
              isParadise: isParadise,
              onTap: () => _openComments(context),
            ),
            const Spacer(),
            _Action(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              isParadise: isParadise,
              onTap: () => _sharePost(context),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Comments bottom sheet ─────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final FeedPost post;
  final String currentUserName;
  final bool isParadise;

  const _CommentsSheet({
    required this.post,
    required this.currentUserName,
    required this.isParadise,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    await context.read<FeedService>().addComment(
          postId: widget.post.id,
          userName: widget.currentUserName,
          text: text,
        );
    _controller.clear();
    HapticService.instance.light();
    setState(() => _submitting = false);
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = widget.isParadise;

    final post = context
        .watch<FeedService>()
        .posts
        .firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);
    final comments = post.comments;
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
    final safeBottom = mq.padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: mq.size.height * 0.65,
        decoration: BoxDecoration(
          color: isParadise ? _pCream : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isParadise ? Border.all(color: _pFuchsia, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isParadise
                    ? _pOrange.withOpacity(0.5)
                    : cs.onSurfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              Text(
                'Comments',
                style: isParadise
                    ? GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: _pBrown)
                    : tt.headlineSmall?.copyWith(
                        fontFamily: 'Georgia', fontWeight: FontWeight.w700),
              ),
              if (comments.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isParadise ? _pTurquoise : cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${comments.length}',
                    style: TextStyle(
                        color: isParadise ? _pWhite : cs.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded,
                    color: isParadise ? _pFuchsia : cs.onSurfaceVariant),
              ),
            ]),
          ),

          Divider(
              height: 1,
              color: isParadise
                  ? _pOrange.withOpacity(0.2)
                  : cs.outline.withOpacity(0.1)),

          // Comment list
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        isParadise
                            ? Icons.chat_bubble_outline_rounded
                            : Icons.chat_bubble_outline,
                        size: 48,
                        color: isParadise
                            ? _pOrchid.withOpacity(0.3)
                            : cs.onSurfaceVariant.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No comments yet.\nBe the first to say something!',
                        textAlign: TextAlign.center,
                        style: isParadise
                            ? GoogleFonts.nunito(
                                color: _pBrown.withOpacity(0.6),
                                fontSize: 15,
                                fontStyle: FontStyle.italic)
                            : tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant.withOpacity(0.8),
                                height: 1.5),
                      ),
                    ]),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      final isMe = c.userName == widget.currentUserName;

                      final avatarColor = isMe
                          ? (isParadise ? _pFuchsia : cs.primary)
                          : (isParadise ? _pYellow : cs.primaryContainer);
                      final avatarTextColor = isMe
                          ? (isParadise ? _pWhite : cs.onPrimary)
                          : (isParadise ? _pBrown : cs.onPrimaryContainer);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: avatarColor,
                            child: Text(
                              c.userName.isNotEmpty
                                  ? c.userName[0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                  fontFamily: isParadise ? null : 'Georgia',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: avatarTextColor),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      c.userName,
                                      style: isParadise
                                          ? GoogleFonts.oswald(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: _pBrown,
                                              letterSpacing: 0.5)
                                          : tt.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _timeAgo(c.postedAt),
                                      style: isParadise
                                          ? GoogleFonts.barlowCondensed(
                                              fontSize: 12,
                                              color: _pTurquoise,
                                              fontWeight: FontWeight.w600)
                                          : tt.labelSmall?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(
                                    c.text,
                                    style: isParadise
                                        ? GoogleFonts.nunito(
                                            fontSize: 15,
                                            color: _pBrown.withOpacity(0.9),
                                            height: 1.4)
                                        : tt.bodyMedium?.copyWith(height: 1.5),
                                  ),
                                ]),
                          ),
                          if (isMe)
                            GestureDetector(
                              onTap: () {
                                HapticService.instance.selection();
                                context.read<FeedService>().deleteComment(
                                      postId: widget.post.id,
                                      commentId: c.id,
                                    );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 4),
                                child: Icon(Icons.delete_outline_rounded,
                                    size: 18,
                                    color: isParadise
                                        ? _pFuchsia.withOpacity(0.6)
                                        : cs.error.withOpacity(0.6)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),

          Divider(
              height: 1,
              color: isParadise
                  ? _pOrange.withOpacity(0.2)
                  : cs.outline.withOpacity(0.1)),

          // Input bar
          Container(
            color: isParadise ? _pWhite : cs.surface,
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, bottomInset > 0 ? 16 : safeBottom + 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  style: isParadise
                      ? GoogleFonts.nunito(fontSize: 15, color: _pBrown)
                      : tt.bodyLarge,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    hintStyle: isParadise
                        ? GoogleFonts.nunito(
                            color: _pBrown.withOpacity(0.4),
                            fontStyle: FontStyle.italic)
                        : tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.6)),
                    filled: true,
                    fillColor: isParadise
                        ? _pCream
                        : cs.surfaceVariant.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: isParadise
                          ? BorderSide(
                              color: _pTurquoise.withOpacity(0.5), width: 1.5)
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: isParadise
                          ? BorderSide(
                              color: _pTurquoise.withOpacity(0.5), width: 1.5)
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: isParadise
                          ? const BorderSide(color: _pTurquoise, width: 2.0)
                          : BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isParadise ? _pGreen : cs.primary,
                    shape: BoxShape.circle,
                    boxShadow: isParadise
                        ? [
                            BoxShadow(
                                color: _pGreen.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: _submitting
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Icon(Icons.send_rounded,
                          size: 20, color: isParadise ? _pWhite : cs.onPrimary),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Post detail bottom sheet ──────────────────────────────────────────────────
class _PostDetailSheet extends StatelessWidget {
  final FeedPost post;
  final bool isParadise;

  const _PostDetailSheet({required this.post, required this.isParadise});

  Color _scoreColor(int s, ColorScheme cs) {
    if (isParadise) {
      if (s >= 80) return _pGreen;
      if (s >= 60) return _pOrange;
      return _pFuchsia;
    } else {
      if (s >= 80) return cs.primary;
      if (s >= 60) return const Color(0xFFF57C00); // Standard Orange
      return cs.error;
    }
  }

  String _scoreLabel(int s) {
    if (s >= 80) return 'Great';
    if (s >= 60) return 'Good';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    final scoreColor = _scoreColor(post.overall, cs);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isParadise ? _pCream : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isParadise ? Border.all(color: _pOrange, width: 3) : null,
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isParadise
                    ? _pTurquoise.withOpacity(0.5)
                    : cs.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isParadise ? _pYellow : cs.secondaryContainer,
                child: Text(
                  post.userName.isNotEmpty
                      ? post.userName[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                      fontFamily: isParadise ? null : 'Georgia',
                      fontWeight: FontWeight.w800,
                      color: isParadise ? _pBrown : cs.onSecondaryContainer,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  post.userName,
                  style: isParadise
                      ? GoogleFonts.oswald(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _pBrown,
                          letterSpacing: 0.5)
                      : tt.headlineSmall?.copyWith(
                          fontFamily: 'Georgia', fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 26,
                    color: isParadise ? _pOrange : cs.onSurfaceVariant),
                onPressed: () {
                  HapticService.instance.light();
                  Navigator.pop(context);
                },
              ),
            ]),
          ),
          Divider(
              height: 1,
              color: isParadise
                  ? _pOrange.withOpacity(0.2)
                  : cs.outline.withOpacity(0.1)),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isParadise ? _pWhite : cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: isParadise
                        ? Border.all(color: _pTurquoise, width: 2.0)
                        : Border.all(
                            color: cs.outline.withOpacity(0.1), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: isParadise
                              ? _pTurquoise.withOpacity(0.15)
                              : cs.shadow.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.topicTitle,
                          style: isParadise
                              ? GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  color: _pBrown,
                                  height: 1.2)
                              : tt.headlineSmall?.copyWith(
                                  fontFamily: 'Georgia',
                                  fontWeight: FontWeight.w800,
                                  height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Practiced with ${post.persona}',
                          style: isParadise
                              ? GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: _pBrown.withOpacity(0.6))
                              : tt.bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Hero Score Circle
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scoreColor.withOpacity(0.1),
                                  border: Border.all(
                                      color: scoreColor.withOpacity(0.3),
                                      width: 2.5),
                                  boxShadow: isParadise
                                      ? [
                                          BoxShadow(
                                              color:
                                                  scoreColor.withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4))
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${post.overall}',
                                          style: TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w800,
                                              fontFamily:
                                                  isParadise ? null : 'Georgia',
                                              color: scoreColor,
                                              height: 1.1),
                                        ),
                                        Text(
                                          _scoreLabel(post.overall),
                                          style: isParadise
                                              ? GoogleFonts.barlowCondensed(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: scoreColor,
                                                  letterSpacing: 1.0)
                                              : tt.labelSmall?.copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: scoreColor),
                                        ),
                                      ]),
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Quick Stats
                              Expanded(
                                child: Column(children: [
                                  _QuickStatRow(
                                    icon: Icons.timer_outlined,
                                    label: 'Duration',
                                    value: post.duration,
                                    isParadise: isParadise,
                                  ),
                                  const SizedBox(height: 16),
                                  _QuickStatRow(
                                    icon: isParadise
                                        ? Icons.spa_rounded
                                        : Icons.calendar_today_rounded,
                                    label: 'Date',
                                    value:
                                        '${post.postedAt.month}/${post.postedAt.day}/${post.postedAt.year}',
                                    isParadise: isParadise,
                                  ),
                                ]),
                              ),
                            ]),
                      ]),
                ),

                const SizedBox(height: 28),

                // Score Breakdown Section
                isParadise
                    ? const _ParadiseSectionLabel('Score Breakdown')
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: cs.primary, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text('Score Breakdown',
                              style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  color: cs.onSurface,
                                  letterSpacing: 0.3,
                                  height: 1.2)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: List.generate(
                                  8,
                                  (i) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          child: Container(
                                              height: 1.5,
                                              color: i.isEven
                                                  ? cs.primary.withOpacity(0.4)
                                                  : cs.primaryContainer
                                                      .withOpacity(0.5)),
                                        ),
                                      )),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.spa_rounded, color: cs.primary, size: 12),
                        ],
                      ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isParadise ? _pWhite : cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: isParadise
                        ? Border.all(color: _pFuchsia, width: 2.0)
                        : Border.all(
                            color: cs.outline.withOpacity(0.1), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: isParadise
                              ? _pFuchsia.withOpacity(0.10)
                              : cs.shadow.withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(children: [
                    _DimensionRow(
                        label: 'Clarity',
                        score: post.clarity,
                        isParadise: isParadise,
                        cs: cs),
                    const SizedBox(height: 20),
                    _DimensionRow(
                        label: 'Pacing',
                        score: post.pacing,
                        isParadise: isParadise,
                        cs: cs),
                    const SizedBox(height: 20),
                    _DimensionRow(
                        label: 'Grammar',
                        score: post.grammar,
                        isParadise: isParadise,
                        cs: cs),
                    const SizedBox(height: 20),
                    _DimensionRow(
                        label: 'Confidence',
                        score: post.confidence,
                        isParadise: isParadise,
                        cs: cs),
                  ]),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _ParadiseSectionLabel extends StatelessWidget {
  final String label;
  const _ParadiseSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              const BoxDecoration(color: _pFuchsia, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: _pBrown,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(
              8,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    height: 1.5,
                    color: i.isEven
                        ? _pFuchsia.withOpacity(0.4)
                        : _pOrange.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.spa_rounded, color: _pGreen, size: 12),
      ],
    );
  }
}

class _QuickStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isParadise;

  const _QuickStatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isParadise = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Row(children: [
      Icon(icon,
          size: 18,
          color:
              isParadise ? _pTurquoise : cs.onSurfaceVariant.withOpacity(0.7)),
      const SizedBox(width: 10),
      Text(label,
          style: isParadise
              ? GoogleFonts.barlowCondensed(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _pBrown.withOpacity(0.6),
                  letterSpacing: 1.0)
              : tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      const Spacer(),
      Text(value,
          style: isParadise
              ? GoogleFonts.oswald(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _pBrown)
              : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}

class _DimensionRow extends StatelessWidget {
  final String label;
  final int score;
  final bool isParadise;
  final ColorScheme cs;

  const _DimensionRow({
    required this.label,
    required this.score,
    required this.isParadise,
    required this.cs,
  });

  Color _dimColor(int s) {
    if (isParadise) {
      if (s >= 80) return _pGreen;
      if (s >= 60) return _pOrange;
      return _pFuchsia;
    } else {
      if (s >= 80) return cs.primary;
      if (s >= 60) return const Color(0xFFF57C00); // Standard Orange
      return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.tt;
    final color = _dimColor(score);

    return Row(children: [
      SizedBox(
        width: 90,
        child: Text(label,
            style: isParadise
                ? GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _pBrown)
                : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isParadise ? 8 : 4),
          child: LinearProgressIndicator(
            value: score / 100,
            color: color,
            backgroundColor: isParadise
                ? color.withOpacity(0.15)
                : cs.outline.withOpacity(0.12),
            minHeight: isParadise ? 10 : 8,
          ),
        ),
      ),
      const SizedBox(width: 16),
      SizedBox(
        width: 32,
        child: Text(
          '$score',
          textAlign: TextAlign.right,
          style: isParadise
              ? GoogleFonts.oswald(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)
              : TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia',
                  color: color),
        ),
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isParadise;
  const _Chip({required this.label, this.isParadise = false});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isParadise
            ? _pFuchsia.withOpacity(0.1)
            : cs.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: isParadise
            ? Border.all(color: _pFuchsia.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Text(label,
          style: isParadise
              ? GoogleFonts.barlowCondensed(
                  color: _pFuchsia,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0)
              : TextStyle(
                  color: cs.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isParadise;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.isParadise = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    final activeColor = isParadise ? _pFuchsia : cs.primary;
    final inactiveColor =
        isParadise ? _pBrown.withOpacity(0.5) : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, size: 20, color: active ? activeColor : inactiveColor),
        const SizedBox(width: 8),
        Text(label,
            style: isParadise
                ? GoogleFonts.barlowCondensed(
                    fontSize: 14,
                    color: active ? activeColor : inactiveColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)
                : tt.labelLarge?.copyWith(
                    color: active ? activeColor : inactiveColor,
                    fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
