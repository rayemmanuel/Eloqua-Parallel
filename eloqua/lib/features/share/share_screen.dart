import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/share_service.dart';
import '../../core/services/feed_service.dart';
import 'score_share_card.dart';

class ShareScreen extends StatefulWidget {
  final int overall, clarity, pacing, grammar, confidence;
  final String topicTitle, duration;

  const ShareScreen({
    super.key,
    required this.overall,
    required this.clarity,
    required this.pacing,
    required this.grammar,
    required this.confidence,
    required this.topicTitle,
    required this.duration,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;
  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final feed = context.read<FeedService>();
    final persona = VibePersona.fromScores(
      clarity: widget.clarity,
      pacing: widget.pacing,
      grammar: widget.grammar,
      confidence: widget.confidence,
    );
    final userName = auth.currentUserName;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Share Your Score'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Persona banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x15000000)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(persona.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Vibe Persona',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600)),
                Text(persona.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text(persona.subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Your share card',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),

          RepaintBoundary(
            key: _boundaryKey,
            child: Center(
              child: ScoreShareCard(
                userName: userName,
                overall: widget.overall,
                clarity: widget.clarity,
                pacing: widget.pacing,
                grammar: widget.grammar,
                confidence: widget.confidence,
                topicTitle: widget.topicTitle,
                duration: widget.duration,
                persona: persona,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Share as image (OS share sheet) ──────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sharing
                  ? null
                  : () async {
                      setState(() => _sharing = true);
                      await ShareService.instance.shareScoreCard(
                        _boundaryKey,
                        'I scored ${widget.overall} on Eloqua! '
                        'My persona: ${persona.title}.',
                      );
                      if (mounted) setState(() => _sharing = false);
                    },
              icon: _sharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(_sharing ? 'Preparing...' : 'Share as Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Post to community feed ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _posting
                  ? null
                  : () async {
                      setState(() => _posting = true);

                      final success = await feed.addPost(
                        userName: userName,
                        overall: widget.overall,
                        clarity: widget.clarity,
                        pacing: widget.pacing,
                        grammar: widget.grammar,
                        confidence: widget.confidence,
                        topicTitle: widget.topicTitle,
                        duration: widget.duration,
                        persona: persona.title,
                      );

                      if (!mounted) return;
                      setState(() => _posting = false);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Posted to community feed!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Could not post — check your connection and try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              icon: _posting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.people_outline, size: 18),
              label: Text(_posting ? 'Posting...' : 'Post to Community Feed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
