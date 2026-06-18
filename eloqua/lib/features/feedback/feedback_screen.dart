import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/strings.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../chat/ai_chat_screen.dart';
import '../share/share_screen.dart';

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

class FeedbackScreen extends StatelessWidget {
  final int durationSecs;
  final int fillerCount;
  final String topicTitle;
  final String mode;
  final String? framework;

  // Passed from practice_screen.dart after POST /analyze completes.
  // Null if the camera was unavailable or the backend call failed.
  final AnalyzeResult? analyzeResult;
  final String? errorMessage;

  const FeedbackScreen({
    super.key,
    required this.durationSecs,
    required this.fillerCount,
    required this.topicTitle,
    this.mode = 'spontaneous',
    this.analyzeResult,
    this.errorMessage,
    this.framework,
  });

  // ── Derived scores ──────────────────────────────────────────────────────────
  int get _overall    => analyzeResult?.combinedScore.round() ?? 0;
  int get _grammar    => analyzeResult?.grammarScore.round() ?? 0;
  int get _confidence => analyzeResult?.eyeContactScore.round() ?? 0;  // eye contact = projected confidence
  int get _clarity    => analyzeResult?.bodyLanguageScore.round() ?? 0; // body language = physical clarity

  int get _pacing {
    final wpm = analyzeResult?.wordsPerMinute ?? 0;
    if (wpm <= 0) return 0;
    if (wpm >= 110 && wpm <= 160) return 100;
    if (wpm < 110) return (wpm / 110 * 100).clamp(0, 100).round();
    return ((1 - (wpm - 160) / 100) * 100).clamp(0, 100).round();
  }

  // ── Derived strengths & improvements from real backend feedback ─────────────
  List<String> get _strengths {
    if (analyzeResult == null)
      return ['Complete a session to see your strengths.'];
    final items = <String>[];
    if (_grammar >= 75)
      items.add(
          'Strong grammar — ${analyzeResult!.grammarScore.round()} / 100.');
    if (_pacing == 100)
      items.add(
          'Great pacing — ${analyzeResult!.wordsPerMinute.round()} wpm is in the ideal range.');
    if (_confidence >= 70) items.add(analyzeResult!.eyeContactFeedback);
    if (analyzeResult!.bodyLanguageScore >= 70)
      items.add(analyzeResult!.postureFeedback);
    if (analyzeResult!.gestureScore >= 40)
      items.add(analyzeResult!.gestureFeedback);
    if (items.isEmpty) items.add('Keep practising — you\'re making progress!');
    return items;
  }

  List<String> get _improvements {
    if (analyzeResult == null)
      return ['Record a session to get personalised tips.'];
    final items = <String>[];
    if (analyzeResult!.totalFillers > 3)
      items.add(
          'Reduce filler words — you used ${analyzeResult!.totalFillers} in this session.');
    if (_pacing < 100) items.add(analyzeResult!.pacingFeedback);
    if (_grammar < 75 && analyzeResult!.grammarSuggestions.isNotEmpty)
      items.add(
          'Grammar: ${analyzeResult!.grammarSuggestions.first['message'] ?? 'Review sentence structure.'}');
    if (_confidence < 70) items.add(analyzeResult!.eyeContactFeedback);
    if (analyzeResult!.postureScore < 70)
      items.add(analyzeResult!.postureFeedback);
    if (items.isEmpty)
      items.add('You\'re doing well — keep up the consistency!');
    return items;
  }

  String get _coachNote {
    if (analyzeResult == null) {
      return errorMessage != null
          ? 'Analysis unavailable: $errorMessage'
          : 'No analysis data — make sure the backend is running and try again.';
    }
    final score = _overall;
    if (score >= 85)
      return 'Excellent session! Your delivery was confident and well-structured. Keep it up.';
    if (score >= 70)
      return 'Solid effort. Focus on the improvement areas above and you\'ll see fast progress.';
    if (score >= 55)
      return 'Good start — consistency is key. Try to reduce filler words and maintain eye contact.';
    return 'Every session counts. Review the tips above and record another session soon.';
  }

  Color _scoreColor(int s, BuildContext context) {
    final isParadise = context.isParadise;
    final cs = context.cs;
    if (s >= 80) return isParadise ? _pGreen : cs.primary;
    if (s >= 60) return isParadise ? _pOrange : const Color(0xFFF57C00);
    return isParadise ? _pFuchsia : cs.error;
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  Widget _buildCoverage(BuildContext context) {
    final cov = analyzeResult?.coverageScore;
    if (analyzeResult == null || cov == null) {
      return const SizedBox.shrink();
    }
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      isParadise
          ? _ParadiseSectionLabel(
              mode == 'preparation' ? 'Content Coverage' : 'Topic Relevance')
          : Text(
              mode == 'preparation' ? 'CONTENT COVERAGE' : 'TOPIC RELEVANCE',
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2),
            ),
      const SizedBox(height: 12),
      Text(analyzeResult!.coverageFeedback ?? '',
          style: isParadise
              ? GoogleFonts.nunito(fontSize: 13, color: _pOrchid)
              : tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 16),
      ...analyzeResult!.coverageReport.map((r) {
        final covered = r['covered'] as bool? ?? false;
        final color = covered
            ? (isParadise ? _pGreen : cs.primary)
            : (isParadise ? _pFuchsia : cs.error);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(
              covered ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['talking_point'] as String? ?? '',
                      style: isParadise
                          ? GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _pBrown)
                          : tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(r['feedback'] as String? ?? '',
                      style: isParadise
                          ? GoogleFonts.nunito(
                              fontSize: 12,
                              color: _pBrown.withOpacity(0.7),
                              height: 1.4)
                          : tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant, height: 1.4)),
                ],
              ),
            ),
          ]),
        );
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;
    final bool hasData = analyzeResult != null;

    return Scaffold(
      backgroundColor: isParadise ? _pWhite : cs.surface,
      appBar: AppBar(
        backgroundColor: isParadise ? cs.primary : cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isParadise ? cs.onPrimary : cs.onSurface,
                  size: 20,
                ),
              )
            : null,
        title: isParadise
            ? Text(
                'FEEDBACK',
                style: GoogleFonts.oswald(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimary,
                  letterSpacing: 3.5,
                ),
              )
            : Text(AppStrings.feedbackTitle,
                style: tt.headlineSmall?.copyWith(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w700,
                )),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (hasData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isParadise
                    ? _pGreen.withOpacity(0.15)
                    : cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isParadise
                        ? _pGreen.withOpacity(0.4)
                        : cs.primary.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: isParadise ? _pGreen : cs.primary),
                const SizedBox(width: 8),
                Text(AppStrings.feedbackSaved,
                    style: TextStyle(
                        color: isParadise ? _pGreen : cs.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
            ),

          if (!hasData)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isParadise
                    ? _pFuchsia.withOpacity(0.1)
                    : cs.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isParadise
                        ? _pFuchsia.withOpacity(0.4)
                        : cs.error.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.error_outline,
                    color: isParadise ? _pFuchsia : cs.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        errorMessage ??
                            'Analysis unavailable. Scores below are not real.',
                        style: TextStyle(
                            color: isParadise ? _pFuchsia : cs.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600))),
              ]),
            ),

          // ── Overall score ring ───────────────────────────────────────────
          Center(
            child: CircularPercentIndicator(
              radius: 80,
              lineWidth: 12,
              percent: (_overall / 100).clamp(0.0, 1.0),
              center: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$_overall',
                    style: isParadise
                        ? GoogleFonts.oswald(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: _pBrown)
                        : TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                Text(AppStrings.feedbackOverall,
                    style: isParadise
                        ? GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _pOrchid)
                        : tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ]),
              progressColor: _scoreColor(_overall, context),
              backgroundColor: isParadise
                  ? _scoreColor(_overall, context).withOpacity(0.15)
                  : cs.outline.withOpacity(0.12),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(topicTitle,
                    style: isParadise
                        ? GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: _pBrown.withOpacity(0.7))
                        : tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center),
                if (framework != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isParadise
                          ? _pFuchsia.withOpacity(0.1)
                          : cs.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isParadise
                            ? _pFuchsia.withOpacity(0.4)
                            : cs.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 12, color: isParadise ? _pFuchsia : cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        '$framework Model',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isParadise ? _pFuchsia : cs.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Score breakdown ──────────────────────────────────────────────
          isParadise
              ? const _ParadiseSectionLabel('Score Breakdown')
              : Text('SCORE BREAKDOWN',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _Bar(
              label: AppStrings.feedbackClarity,
              score: _clarity,
              color: _scoreColor(_clarity, context)),
          _Bar(
              label: AppStrings.feedbackPacing,
              score: _pacing,
              color: _scoreColor(_pacing, context)),
          _Bar(
              label: AppStrings.feedbackGrammar,
              score: _grammar,
              color: _scoreColor(_grammar, context)),
          _Bar(
              label: AppStrings.feedbackConfidence,
              score: _confidence,
              color: _scoreColor(_confidence, context)),

          const SizedBox(height: 24),

          // ── Stats row ────────────────────────────────────────────────────
          Row(children: [
            _StatBox(
                label: 'Duration',
                value: _formatDuration(
                    analyzeResult?.durationSeconds.round() ?? durationSecs)),
            const SizedBox(width: 12),
            _StatBox(
                label: 'Filler Words',
                value: '${analyzeResult?.totalFillers ?? fillerCount}'),
            const SizedBox(width: 12),
            _StatBox(
                label: 'WPM',
                value: analyzeResult != null
                    ? '${analyzeResult!.wordsPerMinute.round()}'
                    : '—'),
          ]),

          // ── Coverage (prep mode) ─────────────────────────────────────────
          _buildCoverage(context),

          const SizedBox(height: 24),

          // ── Strengths / improvements ─────────────────────────────────────
          _Section(
              title: AppStrings.feedbackStrengths,
              items: _strengths,
              color: isParadise ? _pGreen : const Color(0xFF2E7D32),
              icon: Icons.thumb_up_outlined),
          const SizedBox(height: 16),

          _Section(
              title: AppStrings.feedbackImprove,
              items: _improvements,
              color: isParadise ? _pFuchsia : const Color(0xFFE53935),
              icon: Icons.trending_up_rounded),
          const SizedBox(height: 24),

          // ── Coach note ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isParadise ? _pTurquoise : cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border:
                  isParadise ? Border.all(color: _pFuchsia, width: 2.0) : null,
              boxShadow: isParadise
                  ? [
                      BoxShadow(
                          color: _pTurquoise.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.record_voice_over_outlined,
                    color: isParadise ? _pYellow : cs.onPrimaryContainer,
                    size: 18),
                const SizedBox(width: 8),
                Text(AppStrings.feedbackCoachNote,
                    style: isParadise
                        ? GoogleFonts.oswald(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _pCream,
                            letterSpacing: 1.2)
                        : tt.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              Text(_coachNote,
                  style: isParadise
                      ? GoogleFonts.nunito(
                          color: _pCream,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          fontStyle: FontStyle.italic)
                      : tt.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer, height: 1.5)),
            ]),
          ),

          const SizedBox(height: 28),

          // ── Transcript panel ──────────────────────────────────────────────
          isParadise
              ? const _ParadiseSectionLabel('Session Transcript')
              : Text('SESSION TRANSCRIPT',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isParadise ? _pCream : cs.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isParadise
                      ? _pOrange.withOpacity(0.4)
                      : cs.outline.withOpacity(0.1),
                  width: isParadise ? 1.5 : 1.0),
            ),
            child: Text(
              analyzeResult?.transcript != null &&
                      analyzeResult!.transcript.isNotEmpty
                  ? analyzeResult!.transcript
                  : 'No transcript was captured for this session.',
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 14, color: _pBrown, height: 1.6)
                  : tt.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant, height: 1.6),
            ),
          ),

          const SizedBox(height: 36),

          // ── Action buttons ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final latestContext =
                    "Latest Session Just Completed: The user just finished speaking about '$topicTitle'. They scored $_overall/100. Give them feedback focused on their pacing ($_pacing) and filler words ($fillerCount).";

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        AiChatScreen(sessionContext: latestContext),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, anim, __, child) => FadeTransition(
                      opacity: CurvedAnimation(
                          parent: anim, curve: Curves.easeInOut),
                      child: child,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.chat_outlined,
                  size: 18, color: isParadise ? _pBrown : cs.primary),
              label: Text(AppStrings.feedbackChat,
                  style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isParadise ? _pBrown : cs.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isParadise ? _pOrange : cs.primary,
                    width: isParadise ? 2 : 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: isParadise ? _pCream : Colors.transparent,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Tooltip(
            message: hasData ? '' : 'No session data to share yet',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: hasData
                    ? () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ShareScreen(
                              overall: _overall,
                              clarity: _clarity,
                              pacing: _pacing,
                              grammar: _grammar,
                              confidence: _confidence,
                              topicTitle: topicTitle,
                              duration: _formatDuration(
                                  analyzeResult!.durationSeconds.round()),
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
                        )
                    : null,
                icon: Icon(Icons.ios_share_rounded,
                    size: 18,
                    color: isParadise ? _pBrown : cs.onSurfaceVariant),
                label: Text('Share Score',
                    style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isParadise ? _pBrown : cs.onSurfaceVariant)),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: Colors.black26,
                  side: BorderSide(
                      color: hasData
                          ? (isParadise
                              ? _pOrange
                              : cs.onSurfaceVariant.withOpacity(0.5))
                          : Colors.black26,
                      width: isParadise ? 2 : 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: isParadise ? _pCream : Colors.transparent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              icon: Icon(Icons.home_outlined,
                  size: 18, color: isParadise ? _pWhite : cs.onPrimary),
              label: Text(AppStrings.feedbackHome,
                  style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isParadise ? _pWhite : cs.onPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isParadise ? _pFuchsia : cs.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: isParadise ? 6 : 0,
                shadowColor: isParadise ? _pFuchsia.withOpacity(0.5) : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _Bar({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 15, fontWeight: FontWeight.w600, color: _pBrown)
                  : context.tt.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
          Text('$score',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (score / 100).clamp(0.0, 1.0),
          color: color,
          backgroundColor: isParadise
              ? color.withOpacity(0.15)
              : cs.outline.withOpacity(0.1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(50),
        ),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isParadise ? _pCream : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isParadise
                  ? _pOrange.withOpacity(0.4)
                  : cs.outline.withOpacity(0.1),
              width: isParadise ? 1.5 : 1.0),
        ),
        child: Column(children: [
          Text(value,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _pFuchsia)
                  : TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _pOrchid)
                  : TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  const _Section({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isParadise ? _pCream : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isParadise
                ? color.withOpacity(0.5)
                : cs.outline.withOpacity(0.1),
            width: isParadise ? 1.5 : 1.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 16, fontWeight: FontWeight.w600, color: _pBrown)
                  : context.tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.8), shape: BoxShape.circle)),
                Expanded(
                    child: Text(s,
                        style: isParadise
                            ? GoogleFonts.nunito(
                                fontSize: 13, color: _pBrown, height: 1.4)
                            : context.tt.bodyMedium
                                ?.copyWith(color: cs.onSurface, height: 1.4))),
              ]),
            )),
      ]),
    );
  }
}

class _ParadiseSectionLabel extends StatelessWidget {
  final String label;
  const _ParadiseSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
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
            fontSize: 16,
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
