import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
// Note: Ensure your theme_manager_ext.dart is imported here or in a global scope
// import '../../core/theme/theme_manager_ext.dart';
import '../../core/constants/strings.dart';
import '../../core/config/app_config.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager_ext.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;
  _Message({required this.text, required this.isUser}) : time = DateTime.now();
}

class AiChatScreen extends StatefulWidget {
  final String sessionContext;
  const AiChatScreen({super.key, this.sessionContext = ''});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final _msgs = <_Message>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting from coach
    _msgs.add(_Message(text: AppStrings.chatGreeting, isUser: false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Restored your exact backend logic
  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _thinking) return;

    // Kept Classmate's haptic touch
    HapticService.instance.light();

    setState(() {
      _msgs.add(_Message(text: text, isUser: true));
      _thinking = true;
      _ctrl.clear();
    });
    _scrollDown();

    // Build conversation for API
    final history = _msgs
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final systemPrompt = '''
You are Eloqua, an encouraging AI speech coach for college students.
${widget.sessionContext.isNotEmpty ? 'Recent session context: ${widget.sessionContext}' : ''}
Give specific, actionable advice. Keep responses under 100 words.
Include practice exercises when relevant.
Be warm, supportive, and direct.
''';

    try {
      String reply;

      final res = await http
          .post(
            Uri.parse('${AppConfig.mainApiBase}/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'history': history,
              'system_prompt': systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        print('CHAT RESPONSE: ${res.body}');
        if (json['reply'] != null) {
          reply = json['reply'] as String;
        } else {
          reply = json['error'] as String? ?? AppStrings.chatError;
        }
      } else {
        reply = AppStrings.chatError;
      }

      if (mounted) {
        setState(() {
          _msgs.add(_Message(text: reply.trim(), isUser: false));
          _thinking = false;
        });
        _scrollDown();
      }
    } catch (e) {
      print('CHAT ERROR: $e');
      if (mounted) {
        setState(() {
          _msgs.add(_Message(text: AppStrings.chatError, isUser: false));
          _thinking = false;
        });
      }
    }
  }

  // Restored your specific mock reply data (kept just in case you use it as a fallback later)
  String _mockReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('filler') ||
        lower.contains('um') ||
        lower.contains('uh')) {
      return 'To reduce filler words, try replacing them with intentional pauses. Before your next sentence, breathe and pause for 1 second instead of saying "um". Practice this: read a paragraph aloud and pause at every comma instead of filling the silence.';
    }
    if (lower.contains('pacing') ||
        lower.contains('fast') ||
        lower.contains('slow')) {
      return 'For better pacing, record yourself reading 150 words in exactly 60 seconds. That is the ideal rate. Practice this until it feels natural, then apply it to your presentations.';
    }
    if (lower.contains('confidence') ||
        lower.contains('nervous') ||
        lower.contains('scared')) {
      return 'Nervousness and excitement feel identical physiologically. Try reframing: "I am excited to share this." Then before your session, take 3 deep slow breaths. Your voice will steady naturally.';
    }
    if (lower.contains('clarity') || lower.contains('pronunciation')) {
      return 'For clearer speech, slow down by 20% and over-articulate consonants slightly. Record yourself and listen back — most speakers are surprised how much they mumble. Tongue twisters are also great daily practice!';
    }
    return 'Great question! The key to improving your speech is consistent deliberate practice. Try recording yourself daily for just 2 minutes on any topic. Review each recording and pick one thing to improve. Small daily gains compound into big results over weeks.';
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isParadise = context.isParadise;
    final cs = context.cs;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, isParadise),
      body: Container(
        decoration: isParadise
            ? BoxDecoration(
                color: cs.surface,
                image: const DecorationImage(
                  image: AssetImage('assets/images/mesh_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.08,
                ),
              )
            : null,
        child: Column(
          children: [
            // Paradise: decorative banner
            if (isParadise) ...[
              const _ParadiseChatBanner(),
              const SizedBox(height: 8),
            ],

            // Quick chips (Kept from Classmate's code, but integrated properly)
            _QuickChips(
              onChip: (t) {
                _ctrl.text = t;
                _send();
              },
              isParadise: isParadise,
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _msgs.length + (_thinking ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_thinking && i == _msgs.length) {
                    return _ThinkingBubble(isParadise: isParadise);
                  }
                  return _Bubble(message: _msgs[i], isParadise: isParadise);
                },
              ),
            ),

            // Input bar
            _InputBar(ctrl: _ctrl, onSend: _send, isParadise: isParadise),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isParadise) {
    final cs = context.cs;
    final tt = context.tt;

    return AppBar(
      backgroundColor: isParadise ? cs.primary : cs.surface,
      elevation: isParadise ? 8 : 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () {
          HapticService.instance.light();
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: isParadise ? cs.onPrimary : cs.onSurface,
          size: 18,
        ),
      ),
      title: isParadise
          ? Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'E',
                      style: GoogleFonts.sacramento(
                        fontSize: 20,
                        color: cs.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eloqua Coach',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: cs.onPrimary,
                      ),
                    ),
                    Text(
                      'Your AI Speech Guide',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: cs.onPrimary.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onPrimaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.chatTitle,
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'AI Speech Coach',
                      style:
                          tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                isParadise ? cs.secondary.withOpacity(0.2) : cs.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isParadise ? cs.secondary : cs.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.volume_up_rounded,
            color: isParadise ? cs.secondary : cs.onSurfaceVariant,
            size: 18,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARADISE CHAT BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _ParadiseChatBanner extends StatelessWidget {
  const _ParadiseChatBanner();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.tertiary.withOpacity(0.9),
              cs.secondaryContainer.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.secondary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cs.tertiary.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_rounded, color: cs.secondary, size: 12),
                const SizedBox(width: 4),
                Icon(Icons.local_florist_rounded, color: cs.surface, size: 14),
                const SizedBox(width: 4),
                Icon(Icons.spa_rounded, color: cs.secondary, size: 12),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Chat with Eloqua',
              style: GoogleFonts.sacramento(
                fontSize: 28,
                color: cs.secondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Get personalized speech coaching instantly',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: cs.surface.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK CHIPS
// ─────────────────────────────────────────────────────────────────────────────

class _QuickChips extends StatelessWidget {
  final void Function(String) onChip;
  final bool isParadise;
  const _QuickChips({required this.onChip, this.isParadise = false});

  static const _chips = ['Need a hint?', 'Skip for now', 'Show tips'];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            HapticService.instance.light();
            onChip(_chips[i]);
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isParadise
                    ? cs.primary.withOpacity(0.3)
                    : cs.outlineVariant,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isParadise
                      ? cs.primary.withOpacity(0.1)
                      : cs.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _chips[i],
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: 0.5,
                    )
                  : context.tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final _Message message;
  final bool isParadise;
  const _Bubble({required this.message, this.isParadise = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final cs = context.cs;
    final tt = context.tt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isParadise ? cs.tertiary : cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'E',
                  style: isParadise
                      ? GoogleFonts.sacramento(
                          fontSize: 18,
                          color: cs.onTertiary,
                          fontWeight: FontWeight.w700,
                        )
                      : TextStyle(
                          fontSize: 14,
                          color: cs.onPrimaryContainer,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? cs.primary
                    : (isParadise ? cs.surface : cs.surfaceVariant),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isParadise
                            ? cs.primary.withOpacity(0.2)
                            : cs.outlineVariant,
                        width: 0.5,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? cs.primary : cs.shadow)
                        .withOpacity(isUser ? 0.2 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: isParadise
                    ? GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isUser ? cs.onPrimary : cs.onSurface,
                        height: 1.5,
                      )
                    : tt.bodyMedium?.copyWith(
                        color: isUser ? cs.onPrimary : cs.onSurface,
                        height: 1.5,
                      ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THINKING BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _ThinkingBubble extends StatefulWidget {
  final bool isParadise;
  const _ThinkingBubble({this.isParadise = false});

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.isParadise ? cs.tertiary : cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'E',
                style: widget.isParadise
                    ? GoogleFonts.sacramento(
                        fontSize: 18,
                        color: cs.onTertiary,
                        fontWeight: FontWeight.w700,
                      )
                    : TextStyle(
                        fontSize: 14,
                        color: cs.onPrimaryContainer,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isParadise ? cs.surface : cs.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isParadise
                    ? cs.primary.withOpacity(0.2)
                    : cs.outlineVariant,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.28;
                  final val = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
                  final opacity = val < 0.5 ? val * 2 : (1 - val) * 2;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Opacity(
                      opacity: opacity.clamp(0.3, 1.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.isParadise
                              ? cs.tertiary
                              : cs.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final bool isParadise;
  const _InputBar({
    required this.ctrl,
    required this.onSend,
    this.isParadise = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: isParadise ? cs.primary.withOpacity(0.2) : cs.outlineVariant,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isParadise ? cs.surface : cs.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isParadise
                      ? cs.primary.withOpacity(0.25)
                      : cs.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: isParadise
                    ? GoogleFonts.nunito(
                        fontSize: 14,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      )
                    : context.tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                decoration: InputDecoration(
                  hintText: AppStrings.chatPlaceholder,
                  hintStyle: isParadise
                      ? GoogleFonts.nunito(
                          fontSize: 13,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        )
                      : context.tt.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              HapticService.instance.medium();
              onSend();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: cs.onPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
