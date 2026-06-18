import 'package:flutter/material.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/strings.dart';
import '../chat/ai_chat_screen.dart';
import '../share/share_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionData session;
  const SessionDetailScreen({super.key, required this.session});

  Color _scoreColor(BuildContext context, int s) {
    if (s >= 80) return context.cs.primary;
    if (s >= 60) return const Color(0xFFF57C00);
    return context.cs.error;
  }

  String _scoreLabel(int s) {
    if (s >= 80) return 'Great';
    if (s >= 60) return 'Good';
    return 'Needs Work';
  }

  String _formattedDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  String _formatFullDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year}  ·  $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final scoreColor = _scoreColor(context, session.overallScore);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _TopBar(
                onBack: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // ── Hero score card ───────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                              color: cs.shadow.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic + mode badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  session.topic,
                                  style: tt.titleLarge?.copyWith(
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                      height: 1.2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  session.mode == 'preparation'
                                      ? AppStrings.historyPrep
                                      : AppStrings.historySpont,
                                  style: tt.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(
                            _formatFullDate(session.date),
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),

                          const SizedBox(height: 48),

                          // Overall score + label + quick stats
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Big score circle
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scoreColor.withOpacity(0.1),
                                  border: Border.all(
                                      color: scoreColor.withOpacity(0.3),
                                      width: 2),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${session.overallScore}',
                                        style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: scoreColor,
                                            height: 1.1),
                                      ),
                                      Text(
                                        _scoreLabel(session.overallScore),
                                        style: tt.labelSmall?.copyWith(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: scoreColor.withOpacity(0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 24),

                              // Quick stats column
                              Expanded(
                                child: Column(
                                  children: [
                                    _QuickStat(
                                      icon: Icons.timer_outlined,
                                      label: 'Duration',
                                      value: _formattedDuration(
                                          session.durationSeconds),
                                      cs: cs,
                                      tt: tt,
                                    ),
                                    const SizedBox(height: 10),
                                    _QuickStat(
                                      icon: Icons.chat_bubble_outline,
                                      label: 'Filler words',
                                      value: '${session.fillerCount}',
                                      valueColor: session.fillerCount <= 3
                                          ? cs.primary
                                          : session.fillerCount <= 6
                                              ? const Color(0xFFF57C00)
                                              : cs.error,
                                      cs: cs,
                                      tt: tt,
                                    ),
                                    const SizedBox(height: 10),
                                    _QuickStat(
                                      icon: Icons.person_outline,
                                      label: 'Coach persona',
                                      value: session.persona,
                                      cs: cs,
                                      tt: tt,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Dimension breakdown ───────────────────────────────────────────
                    const _SectionLabel('Score Breakdown'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                              color: cs.shadow.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          _DimensionRow(
                              label: 'Clarity',
                              score: session.clarity,
                              context: context),
                          const SizedBox(height: 16),
                          _DimensionRow(
                              label: 'Pacing',
                              score: session.pacing,
                              context: context),
                          const SizedBox(height: 16),
                          _DimensionRow(
                              label: 'Grammar',
                              score: session.grammar,
                              context: context),
                          const SizedBox(height: 16),
                          _DimensionRow(
                              label: 'Confidence',
                              score: session.confidence,
                              context: context),
                          const SizedBox(height: 16),
                          _DimensionRow(
                              // ← add
                              label: 'Relevance',
                              score: session.relevance,
                              context: context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Tips panel ────────────────────────────────────────────────────
                    const _SectionLabel('Areas to Focus On'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                              color: cs.shadow.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildTips(context),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Transcript panel ──────────────────────────────────────────────
                    const _SectionLabel('Session Transcript'),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outline.withOpacity(0.1)),
                      ),
                      child: Text(
                        // Simply reading the transcript from the model now
                        session.transcript != null &&
                                session.transcript!.isNotEmpty
                            ? session.transcript!
                            : 'No transcript was captured for this session.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Action Buttons ────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final specificContext =
                              "Specific Session Discussion: The user is asking about their past session on the topic '${session.topic}'. They scored ${session.overallScore}/100. Breakdown: Clarity (${session.clarity}), Pacing (${session.pacing}), Grammar (${session.grammar}), Confidence (${session.confidence}), Relevance (${session.relevance}), Fillers used: ${session.fillerCount}. Coach persona: ${session.persona}.";

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  AiChatScreen(sessionContext: specificContext),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(
                                opacity: CurvedAnimation(
                                    parent: anim, curve: Curves.easeInOut),
                                child: child,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.chat_outlined,
                            size: 18, color: cs.primary),
                        label: Text('Discuss with AI Coach',
                            style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: cs.primary.withOpacity(0.5), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ShareScreen(
                              overall: session.overallScore,
                              clarity: session.clarity,
                              pacing: session.pacing,
                              grammar: session.grammar,
                              confidence: session.confidence,
                              topicTitle: session.topic,
                              duration:
                                  _formattedDuration(session.durationSeconds),
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: anim, curve: Curves.easeInOut),
                              child: child,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.ios_share_rounded,
                            size: 18, color: cs.onSurfaceVariant),
                        label: Text('Share Score',
                            style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTips(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final dims = {
      'Clarity': session.clarity,
      'Pacing': session.pacing,
      'Grammar': session.grammar,
      'Confidence': session.confidence,
      'Relevance': session.relevance,
    };

    final tips = <_TipData>[];

    if (session.fillerCount > 6) {
      tips.add(_TipData(
        label: 'Reduce filler words',
        detail: 'You used ${session.fillerCount} fillers this session. '
            'Try pausing silently instead of saying "um" or "uh".',
        color: cs.error,
      ));
    }

    final sorted = dims.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in sorted.take(2)) {
      if (entry.value < 75) {
        tips.add(_TipData(
          label: '${entry.key}: ${entry.value}/100',
          detail: _tipText(entry.key, entry.value),
          color: _scoreColor(context, entry.value),
        ));
      }
    }

    if (tips.isEmpty) {
      return [
        Row(children: [
          Icon(Icons.check_circle_outline, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Text('Great job! All dimensions are strong.',
              style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        ]),
      ];
    }

    return tips
        .map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.label,
                            style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface)),
                        const SizedBox(height: 4),
                        Text(t.detail,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  String _tipText(String dim, int score) {
    switch (dim) {
      case 'Clarity':
        return 'Work on enunciating each word clearly. Slow down slightly so your ideas land.';
      case 'Pacing':
        return score < 60
            ? 'Try to pick up your pace slightly — aim for 120–150 words per minute.'
            : 'Your pace is a little fast. Breathe between ideas.';
      case 'Grammar':
        return 'Practice complete sentences before speaking. Reading aloud daily can help build fluency.';
      case 'Confidence':
        return 'Maintain steady eye contact and an upright posture. Project your voice to the back of the room.';
      case 'Relevance': // ← add
        return 'Try to stay focused on the topic throughout. Open with a clear statement about it and make sure every point connects back.';
      default:
        return 'Keep practicing to improve this dimension.';
    }
  }
}

// ── GLOBAL THEMED COMPONENTS ───────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

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
        GestureDetector(
          onTap: onBack,
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
                Icon(Icons.arrow_back_rounded, size: 18, color: cs.onPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text('SESSION DETAILS',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onPrimary,
                letterSpacing: 2.0)),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
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
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Container(
                            height: 1.5,
                            color: i.isEven
                                ? cs.primary.withOpacity(0.4)
                                : cs.primaryContainer.withOpacity(0.5)),
                      ),
                    )),
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.spa_rounded, color: cs.primary, size: 12),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ColorScheme cs;
  final TextTheme tt;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(
            width: 16), // Replaced Spacer to give minimum breathing room
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right, // Keeps it aligned to the right
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Adds "..." if text is too long
            style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w700, color: valueColor ?? cs.onSurface),
          ),
        ),
      ]);
}

class _DimensionRow extends StatelessWidget {
  final String label;
  final int score;
  final BuildContext context;

  const _DimensionRow({
    required this.label,
    required this.score,
    required this.context,
  });

  Color _scoreColor(BuildContext context, int s) {
    if (s >= 80) return context.cs.primary;
    if (s >= 60) return const Color(0xFFF57C00);
    return context.cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final color = _scoreColor(context, score);

    return Row(children: [
      SizedBox(
        width: 90,
        child: Text(label,
            style: tt.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            color: color,
            backgroundColor: cs.outline.withOpacity(0.12),
            minHeight: 8,
          ),
        ),
      ),
      const SizedBox(width: 14),
      SizedBox(
        width: 32,
        child: Text(
          '$score',
          textAlign: TextAlign.right,
          style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color),
        ),
      ),
    ]);
  }
}

class _TipData {
  final String label;
  final String detail;
  final Color color;
  const _TipData({
    required this.label,
    required this.detail,
    required this.color,
  });
}
